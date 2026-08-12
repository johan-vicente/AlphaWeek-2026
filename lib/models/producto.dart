class Producto {
  final String codigoBarra;
  final String nombre;
  final String tipoVenta; // "empacado" o "peso_variable"
  final double? precio;
  final double? precioPorLibra;
  final String categoria;
  final String? imagenUrl;
  final List<dynamic> sucursales;
  final List<dynamic> productosSimilares;

  Producto({
    required this.codigoBarra,
    required this.nombre,
    required this.tipoVenta,
    this.precio,
    this.precioPorLibra,
    required this.categoria,
    this.imagenUrl,
    this.sucursales = const [],
    this.productosSimilares = const [],
  });

  // Convierte los datos que vienen de Firebase en un objeto Producto
  factory Producto.fromMap(String codigo, Map<dynamic, dynamic> data) {
    return Producto(
      codigoBarra: codigo,
      nombre: data['nombre'] ?? '',
      tipoVenta: data['tipo_venta'] ?? 'empacado',
      precio: (data['precio'] as num?)?.toDouble(),
      precioPorLibra: (data['precio_por_libra'] as num?)?.toDouble(),
      categoria: data['categoria'] ?? '',
      imagenUrl: data['imagen_url'],
      sucursales: data['sucursales'] ?? [],
      productosSimilares: data['productos_similares'] ?? [],
    );
  }

  // Convierte el objeto Producto de vuelta a un Map para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo_venta': tipoVenta,
      if (precio != null) 'precio': precio,
      if (precioPorLibra != null) 'precio_por_libra': precioPorLibra,
      'categoria': categoria,
      'imagen_url': imagenUrl,
      'sucursales': sucursales,
      'productos_similares': productosSimilares,
    };
  }

  // Precio final a mostrar, según el tipo de venta
  double calcularPrecio({double libras = 1}) {
    if (tipoVenta == 'peso_variable' && precioPorLibra != null) {
      return precioPorLibra! * libras;
    }
    return precio ?? 0;
  }
}