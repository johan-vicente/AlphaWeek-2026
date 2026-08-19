import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../services/cart_service.dart';

/// Definiciones de las tools que la IA puede usar, en el formato que
/// espera la API de Claude (tool use / function calling).
class ToolsIA {
  static final FirebaseService _firebaseService = FirebaseService();

  /// Guarda los productos reales que las tools encontraron en el turno
  /// actual, para que la pantalla de chat los muestre como tarjetas.
  /// Se limpia al inicio de cada mensaje nuevo del usuario.
  static List<Producto> ultimosProductosMostrados = [];

  /// Se pone en true cuando agregar_al_carrito tuvo éxito en el turno
  /// actual, para que la pantalla de chat muestre el botón "Ver carrito".
  static bool seAgregoAlCarrito = false;

  static List<Map<String, dynamic>> get definiciones => [
    {
      'name': 'buscar_producto',
      'description':
      'Busca productos reales en el catálogo de Sirena por nombre o '
          'palabra clave. Úsala SIEMPRE antes de mencionar o proponer '
          'cualquier producto — nunca asumas que un producto existe sin '
          'buscarlo primero. Puede devolver varios resultados o ninguno.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'nombre': {
            'type': 'string',
            'description':
            'Nombre o palabra clave del producto a buscar, ej. '
                '"arroz", "café", "detergente"',
          },
        },
        'required': ['nombre'],
      },
    },
    {
      'name': 'consultar_disponibilidad_sucursal',
      'description':
      'Verifica si un producto específico está disponible en una '
          'sucursal determinada. Úsala cuando el usuario pregunte '
          '"¿tienen tal producto en tal sucursal?". Primero busca el '
          'producto con buscar_producto si no tienes su código de barra.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'codigo_barra': {
            'type': 'string',
            'description': 'Código de barra del producto a verificar',
          },
          'sucursal_id': {
            'type': 'string',
            'description':
            'ID de la sucursal: "autopista_san_isidro", "las_americas", o "villa_mella"',
          },
        },
        'required': ['codigo_barra', 'sucursal_id'],
      },
    },
    {
      'name': 'armar_lista_por_presupuesto',
      'description':
      'Arma una lista de compras aproximada dado un presupuesto en '
          'pesos dominicanos. El resultado nunca será exacto al monto — '
          'se acerca lo más posible sin pasarse mucho. El usuario decide '
          'después qué agregar o quitar de la propuesta.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'presupuesto': {
            'type': 'number',
            'description': 'Monto disponible en pesos dominicanos (RD\$)',
          },
          'categoria': {
            'type': 'string',
            'description':
            'Categoría opcional para enfocar la lista, ej. '
                '"Limpieza", "Despensa". Si no se especifica, mezcla de '
                'varias categorías.',
          },
        },
        'required': ['presupuesto'],
      },
    },
    {
      'name': 'agregar_al_carrito',
      'description':
      'Agrega uno o más productos reales al carrito de compras del '
          'usuario. SOLO usa códigos de barra que hayan salido de '
          'buscar_producto o armar_lista_por_presupuesto en esta misma '
          'conversación — nunca inventes un código. Llama esta tool una '
          'vez por cada producto a agregar.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'codigo_barra': {
            'type': 'string',
            'description': 'Código de barra exacto del producto a agregar',
          },
          'cantidad': {
            'type': 'integer',
            'description':
            'Cantidad de unidades (solo para productos empacados). Default 1.',
          },
          'libras': {
            'type': 'number',
            'description':
            'Cantidad de libras (solo para productos de peso variable). Default 1.',
          },
        },
        'required': ['codigo_barra'],
      },
    },
  ];

  static Future<Map<String, dynamic>> ejecutar(
      String nombreTool,
      Map<String, dynamic> input,
      ) async {
    switch (nombreTool) {
      case 'buscar_producto':
        return _buscarProducto(input);
      case 'consultar_disponibilidad_sucursal':
        return _consultarDisponibilidad(input);
      case 'armar_lista_por_presupuesto':
        return _armarListaPorPresupuesto(input);
      case 'agregar_al_carrito':
        return _agregarAlCarrito(input);
      default:
        return {'error': 'Tool desconocida: $nombreTool'};
    }
  }

  static Future<Map<String, dynamic>> _buscarProducto(
      Map<String, dynamic> input,
      ) async {
    final nombre = input['nombre'] as String? ?? '';
    final resultados = await _firebaseService.buscarProductosPorNombre(nombre);

    if (resultados.isEmpty) {
      return {'encontrados': 0, 'productos': []};
    }

    ultimosProductosMostrados.addAll(resultados);

    return {
      'encontrados': resultados.length,
      'productos': resultados.map(_productoParaIA).toList(),
    };
  }

  static Future<Map<String, dynamic>> _consultarDisponibilidad(
      Map<String, dynamic> input,
      ) async {
    final codigo = input['codigo_barra'] as String? ?? '';
    final sucursalId = input['sucursal_id'] as String? ?? '';

    final producto = await _firebaseService.obtenerProductoPorCodigo(codigo);
    if (producto == null) {
      return {'disponible': false, 'razon': 'Producto no encontrado'};
    }

    final disponible = producto.sucursales.contains(sucursalId);
    return {
      'disponible': disponible,
      'producto': producto.nombre,
      'sucursal_id': sucursalId,
    };
  }

  static Future<Map<String, dynamic>> _armarListaPorPresupuesto(
      Map<String, dynamic> input,
      ) async {
    final presupuesto = (input['presupuesto'] as num?)?.toDouble() ?? 0;
    final categoria = input['categoria'] as String?;

    final todos = await _firebaseService.buscarProductosPorNombre('');
    final candidatos = categoria != null
        ? todos.where((p) => p.categoria == categoria).toList()
        : todos;

    candidatos.shuffle();
    final seleccionados = <Producto>[];
    double acumulado = 0;

    for (final p in candidatos) {
      final precio = p.calcularPrecio();
      if (acumulado + precio <= presupuesto) {
        seleccionados.add(p);
        acumulado += precio;
      }
    }

    ultimosProductosMostrados.addAll(seleccionados);

    return {
      'presupuesto_pedido': presupuesto,
      'total_aproximado': acumulado,
      'productos': seleccionados.map(_productoParaIA).toList(),
    };
  }

  static Future<Map<String, dynamic>> _agregarAlCarrito(
      Map<String, dynamic> input,
      ) async {
    final codigo = input['codigo_barra'] as String? ?? '';
    final cantidad = (input['cantidad'] as num?)?.toInt() ?? 1;
    final libras = (input['libras'] as num?)?.toDouble() ?? 1.0;

    final producto = await _firebaseService.obtenerProductoPorCodigo(codigo);
    if (producto == null) {
      return {
        'exito': false,
        'razon': 'Producto no encontrado con ese código',
      };
    }

    CartService().addItem(
      producto: producto,
      cantidad: cantidad,
      libras: producto.tipoVenta == 'peso_variable' ? libras : 0.0,
    );

    seAgregoAlCarrito = true;

    return {
      'exito': true,
      'producto': producto.nombre,
      'agregado': producto.tipoVenta == 'peso_variable'
          ? '$libras lb'
          : '$cantidad unidad(es)',
    };
  }

  /// Versión reducida del producto — solo lo que la IA necesita para
  /// decidir y responder, sin mandarle todo el objeto completo (ahorra tokens).
  static Map<String, dynamic> _productoParaIA(Producto p) {
    return {
      'codigo_barra': p.codigoBarra,
      'nombre': p.nombre,
      'categoria': p.categoria,
      'tipo_venta': p.tipoVenta,
      'precio': p.calcularPrecio(),
      'imagen_url': p.imagenUrl,
    };
  }
}