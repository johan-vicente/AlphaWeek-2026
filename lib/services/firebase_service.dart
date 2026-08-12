import 'package:firebase_database/firebase_database.dart';
import '../models/producto.dart';
import '../models/nodo_grafo.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Busca un producto exacto por su código de barras/PLU
  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    final snapshot = await _db.child('productos/$codigo').get();
    if (!snapshot.exists) return null;
    return Producto.fromMap(codigo, snapshot.value as Map<dynamic, dynamic>);
  }

  // Busca productos por nombre (para los de peso variable, sin código escaneable)
  Future<List<Producto>> buscarProductosPorNombre(String query) async {
    final snapshot = await _db.child('productos').get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    final resultados = <Producto>[];

    data.forEach((codigo, valor) {
      final producto = Producto.fromMap(codigo, valor as Map<dynamic, dynamic>);
      if (producto.nombre.toLowerCase().contains(query.toLowerCase())) {
        resultados.add(producto);
      }
    });

    return resultados;
  }

  // Escucha en tiempo real el estado de las cajas de una sucursal
  Stream<Map<dynamic, dynamic>> escucharCajas(String sucursalId) {
    return _db.child('sucursales/$sucursalId/cajas').onValue.map((event) {
      if (event.snapshot.value == null) return {};
      return event.snapshot.value as Map<dynamic, dynamic>;
    });
  }

  // Obtiene el grafo de navegación de una sucursal (formato crudo de Firebase)
  Future<Map<dynamic, dynamic>> obtenerGrafo(String sucursalId) async {
    final snapshot = await _db.child('sucursales/$sucursalId/grafo/nodos').get();
    if (!snapshot.exists) return {};
    return snapshot.value as Map<dynamic, dynamic>;
  }

  // Obtiene el grafo ya convertido a objetos NodoGrafo, listo para usar con RutaService
  Future<Map<String, NodoGrafo>> obtenerGrafoComoNodos(String sucursalId) async {
    final raw = await obtenerGrafo(sucursalId);
    return raw.map((key, value) =>
        MapEntry(key as String, NodoGrafo.fromMap(key, value as Map<dynamic, dynamic>)));
  }
}