class Caja {
  final String id;
  final String nombre;
  final bool habilitada;

  Caja({
    required this.id,
    required this.nombre,
    required this.habilitada,
  });

  factory Caja.fromMap(String id, Map<dynamic, dynamic> data) {
    return Caja(
      id: id,
      nombre: data['nombre'] ?? 'Caja',
      habilitada: data['habilitada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nombre': nombre, 'habilitada': habilitada};
  }
}