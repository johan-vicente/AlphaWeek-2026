class Promocion {
  final String imagenAsset;
  final String titulo;
  final String descripcion;
  final String? categoriaRelacionada;

  Promocion({
    required this.imagenAsset,
    required this.titulo,
    required this.descripcion,
    this.categoriaRelacionada,
  });
}