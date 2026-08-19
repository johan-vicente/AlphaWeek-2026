import '../models/producto.dart';
import '../services/firebase_service.dart';

/// Definiciones de las tools que la IA puede usar, en el formato que
/// espera la API de Claude (tool use / function calling).
class ToolsIA {
  static final FirebaseService _firebaseService = FirebaseService();

  /// Lista de definiciones de tools para pasarle a ClaudeService.enviarMensaje().
  /// Empezamos solo con buscar_producto — las demás se agregan aquí mismo
  /// a medida que las construyamos.
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
  ];

  /// Ejecuta la tool que la IA pidió y devuelve el resultado ya listo
  /// para mandarlo de vuelta a Claude como tool_result.
  static Future<Map<String, dynamic>> ejecutar(
      String nombreTool,
      Map<String, dynamic> input,
      ) async {
    switch (nombreTool) {
      case 'buscar_producto':
        return _buscarProducto(input);
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

    return {
      'encontrados': resultados.length,
      'productos': resultados.map(_productoParaIA).toList(),
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
      'precio': p.calcularPrecio(), // usa el default de 1 libra si es peso_variable
      'imagen_url': p.imagenUrl,
    };
  }
}