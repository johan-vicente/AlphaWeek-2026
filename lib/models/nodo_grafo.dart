class NodoGrafo {
  final String id;
  final String tipo; // entrada, interseccion, zona, caja, salida
  final double x;
  final double y;
  final List<String> conexiones;

  NodoGrafo({
    required this.id,
    required this.tipo,
    required this.x,
    required this.y,
    required this.conexiones,
  });

  factory NodoGrafo.fromMap(String id, Map<dynamic, dynamic> data) {
    return NodoGrafo(
      id: id,
      tipo: data['tipo'] ?? '',
      x: (data['x'] as num).toDouble(),
      y: (data['y'] as num).toDouble(),
      conexiones: List<String>.from(data['conexiones'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'tipo': tipo, 'x': x, 'y': y, 'conexiones': conexiones};
  }
}