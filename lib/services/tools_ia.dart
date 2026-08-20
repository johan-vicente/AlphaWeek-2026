import '../models/producto.dart';
import '../models/promocion.dart';
import '../services/firebase_service.dart';
import '../services/cart_service.dart';
import '../services/promociones_service.dart';

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

  /// Guarda las promociones consultadas en el turno actual, para que la
  /// pantalla de chat muestre sus imágenes.
  static List<Promocion> ultimasPromosMostradas = [];

  static const Map<String, List<String>> _recetasConocidas = {
    'sancocho': [
      '01004', // Cebolla Roja Criolla
      'A00002', // Plátano Verde
      'A6954821584253', // Ajo Selecto
      'A2100003188489', // Orégano Molido Wala
      'A2100003198181', // Sazón Completo Wala
      'A2100002986895', // Sal Refinada Wala
      'A2100003032201', // Vinagre Blanco Wala
      'A7468827171465', // Cilantro Ancho
      '02296', // Yuca Parafinada
      '01007', // Ñame Fresco
      '01010', // Yautía Blanca
      '02012', // Auyama Criolla
      '01002', // Batata Fresca
      '06003', // Filete Pechuga Pollo Cibao
      '05044', // Chuleta Cerdo Ahumada
    ],
  };

  static Future<Map<String, dynamic>> _armarListaReceta(
      Map<String, dynamic> input,
      ) async {
    final receta = (input['receta'] as String? ?? '').toLowerCase().trim();
    final codigos = _recetasConocidas[receta];

    if (codigos == null) {
      return {
        'encontrada': false,
        'mensaje': 'No tengo esa receta precargada todavía.',
      };
    }

    final productos = <Producto>[];
    for (final codigo in codigos) {
      final producto = await _firebaseService.obtenerProductoPorCodigo(codigo);
      if (producto != null) productos.add(producto);
    }

    ultimosProductosMostrados.addAll(productos);

    return {
      'encontrada': true,
      'receta': receta,
      'total_ingredientes': productos.length,
      'productos': productos.map(_productoParaIA).toList(),
    };
  }

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
      'name': 'identificar_producto_por_imagen',
      'description':
      'Identifica un producto basándose en una imagen subida por el usuario '
          'y lo busca en el catálogo real. Úsala SIEMPRE que el usuario suba '
          'una foto para saber de qué producto se trata. Usa las palabras clave '
          'más distintivas de la imagen.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'descripcion_visual': {
            'type': 'string',
            'description':
            'Descripción clara o nombre probable del producto que ves '
                'en la foto (marca, tipo, presentación) para buscarlo en la base de datos.',
          },
        },
        'required': ['descripcion_visual'],
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
    {
      'name': 'consultar_ofertas',
      'description':
      'Consulta las promociones y ofertas activas de Sirena. Úsala cuando '
          'el usuario pregunte por ofertas, promociones, especiales del día, '
          'o descuentos.',
      'input_schema': {
        'type': 'object',
        'properties': {},
      },

    },

    {
      'name': 'armar_lista_receta',
      'description':
      'Arma la lista de ingredientes EXACTA y ya verificada para una receta '
          'dominicana específica que tenemos precargada (por ahora: sancocho). '
          'Úsala SIEMPRE que el usuario pida ingredientes/lista para hacer '
          'sancocho, en vez de buscar_producto — esta lista ya está curada y '
          'evita resultados incorrectos.',
      'input_schema': {
        'type': 'object',
        'properties': {
          'receta': {
            'type': 'string',
            'description': 'Nombre de la receta. Valores válidos: "sancocho"',
          },
        },
        'required': ['receta'],
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
      case 'identificar_producto_por_imagen':
        return _identificarProductoPorImagen(input);
      case 'consultar_disponibilidad_sucursal':
        return _consultarDisponibilidad(input);
      case 'armar_lista_por_presupuesto':
        return _armarListaPorPresupuesto(input);
      case 'agregar_al_carrito':
        return _agregarAlCarrito(input);
      case 'consultar_ofertas':
        return _consultarOfertas();
      case 'armar_lista_receta':
        return _armarListaReceta(input);
      default:
        return {'error': 'Tool desconocida: $nombreTool'};
    }
  }

  static Future<Map<String, dynamic>> _identificarProductoPorImagen(
      Map<String, dynamic> input,
      ) async {
    final descripcion = input['descripcion_visual'] as String? ?? '';
    final resultados = await _firebaseService.buscarProductosPorNombre(descripcion);

    if (resultados.isEmpty) {
      return {
        'encontrados': 0,
        'mensaje': 'No se encontró nada exacto en el catálogo parecido a: $descripcion'
      };
    }

    ultimosProductosMostrados.addAll(resultados);

    return {
      'encontrados': resultados.length,
      'productos': resultados.map(_productoParaIA).toList(),
    };
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

    if (seleccionados.isEmpty && candidatos.isNotEmpty) {
      candidatos.sort((a, b) => a.calcularPrecio().compareTo(b.calcularPrecio()));
      final masBarato = candidatos.first;
      ultimosProductosMostrados.add(masBarato);
      return {
        'presupuesto_pedido': presupuesto,
        'total_aproximado': masBarato.calcularPrecio(),
        'mensaje': 'El presupuesto es demasiado bajo para armar una lista. El producto más económico disponible cuesta ${masBarato.calcularPrecio()} pesos.',
        'mejor_aproximacion_mas_barata': _productoParaIA(masBarato),
        'productos': [],
      };
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

  static Map<String, dynamic> _consultarOfertas() {
    final promos = PromocionesService.promociones;
    ultimasPromosMostradas = promos;

    return {
      'ofertas_activas': promos
          .map((p) => {'titulo': p.titulo, 'descripcion': p.descripcion})
          .toList(),
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