import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/producto.dart';
import '../models/nodo_grafo.dart';
import 'local_storage_service.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<bool> _hayConexion() async {
    final resultados = await Connectivity().checkConnectivity();
    return !resultados.contains(ConnectivityResult.none);
  }

  // Busca un producto exacto por su código de barras/PLU
  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    if (await _hayConexion()) {
      try {
        final snapshot = await _db.child('productos/$codigo').get().timeout(const Duration(seconds: 2));
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          await LocalStorageService.guardarProducto(codigo, data);
          return Producto.fromMap(codigo, data);
        }
      } catch (e) {
        print('Error obteniendo producto de Firebase: $e');
      }
    }

    // Sin conexión o falló: usar caché directo, sin esperar
    final cachedData = LocalStorageService.obtenerProducto(codigo);
    if (cachedData != null) {
      return Producto.fromMap(codigo, cachedData);
    }
    return null;
  }

  // Busca productos por nombre (para los de peso variable, sin código escaneable)
  Future<List<Producto>> buscarProductosPorNombre(String query) async {
    final resultados = <Producto>[];

    if (await _hayConexion()) {
      try {
        final snapshot = await _db.child('productos').get().timeout(const Duration(seconds: 2));
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          for (var entry in data.entries) {
            final codigo = entry.key;
            final valor = entry.value as Map<dynamic, dynamic>;
            await LocalStorageService.guardarProducto(codigo, valor);
            final producto = Producto.fromMap(codigo, valor);
            if (producto.nombre.toLowerCase().contains(query.toLowerCase())) {
              resultados.add(producto);
            }
          }
          return resultados;
        }
      } catch (e) {
        print('Error buscando productos en Firebase: $e');
      }
    }

    // Sin conexión o falló: buscar entre todos los productos cacheados
    final cachedProducts = LocalStorageService.obtenerTodosLosProductos();
    for (var data in cachedProducts) {
      final codigo = data['codigo_barra'] ?? '';
      final producto = Producto.fromMap(codigo, data);
      if (producto.nombre.toLowerCase().contains(query.toLowerCase())) {
        resultados.add(producto);
      }
    }
    return resultados;
  }

  // Escucha en tiempo real el estado de las cajas de una sucursal
  Stream<Map<dynamic, dynamic>> escucharCajas(String sucursalId) async* {
    final cachedCajas = LocalStorageService.obtenerCajas(sucursalId);
    if (cachedCajas != null) {
      yield cachedCajas;
    }

    if (await _hayConexion()) {
      yield* _db.child('sucursales/$sucursalId/cajas').onValue.map((event) {
        if (event.snapshot.value == null) return {};
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        LocalStorageService.guardarCajas(sucursalId, data);
        return data;
      });
    }
    // Sin conexión: se queda con lo emitido de la caché, sin intentar conectar
  }

  // Obtiene el grafo de navegación de una sucursal
  Future<Map<dynamic, dynamic>> obtenerGrafo(String sucursalId) async {
    if (await _hayConexion()) {
      try {
        final snapshot = await _db.child('sucursales/$sucursalId/grafo/nodos').get().timeout(const Duration(seconds: 2));
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          await LocalStorageService.guardarGrafo(sucursalId, data);
          return data;
        }
      } catch (e) {
        print('Error al obtener grafo de Firebase: $e');
      }
    }

    final cachedGraph = LocalStorageService.obtenerGrafo(sucursalId);
    if (cachedGraph != null) {
      return cachedGraph;
    }
    return {};
  }

  // Obtiene el grafo ya convertido a objetos NodoGrafo, listo para usar con RutaService
  Future<Map<String, NodoGrafo>> obtenerGrafoComoNodos(String sucursalId) async {
    final raw = await obtenerGrafo(sucursalId);
    return raw.map((key, value) =>
        MapEntry(key as String, NodoGrafo.fromMap(key, value as Map<dynamic, dynamic>)));
  }
}