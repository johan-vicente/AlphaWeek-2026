import 'package:firebase_database/firebase_database.dart';
import '../models/producto.dart';
import '../models/nodo_grafo.dart';
import 'local_storage_service.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Busca un producto exacto por su código de barras/PLU
  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    try {
      final snapshot = await _db.child('productos/$codigo').get().timeout(const Duration(seconds: 2));
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Guardar en caché
        await LocalStorageService.guardarProducto(codigo, data);
        return Producto.fromMap(codigo, data);
      }
    } catch (e) {
      print('Error obteniendo producto de Firebase (offline?): $e');
    }

    // Fallback: buscar en caché local
    final cachedData = LocalStorageService.obtenerProducto(codigo);
    if (cachedData != null) {
      return Producto.fromMap(codigo, cachedData);
    }
    return null;
  }

  // Busca productos por nombre (para los de peso variable, sin código escaneable)
  Future<List<Producto>> buscarProductosPorNombre(String query) async {
    final resultados = <Producto>[];
    
    try {
      final snapshot = await _db.child('productos').get().timeout(const Duration(seconds: 2));
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        for (var entry in data.entries) {
          final codigo = entry.key;
          final valor = entry.value as Map<dynamic, dynamic>;
          
          // Guardar cada producto en caché para futuras búsquedas
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

    // Fallback offline: buscar entre todos los productos cacheados
    final cachedProducts = LocalStorageService.obtenerTodosLosProductos();
    for (var data in cachedProducts) {
      // Necesitamos el código; podemos buscarlo dentro del map si existe, 
      // o usar el código_barra que típicamente guardamos.
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
    // 1. Emitimos el estado local cacheado inmediatamente para que no haya pantalla en blanco
    final cachedCajas = LocalStorageService.obtenerCajas(sucursalId);
    if (cachedCajas != null) {
      yield cachedCajas;
    }

    // 2. Escuchamos de Firebase y actualizamos la caché con cada cambio
    yield* _db.child('sucursales/$sucursalId/cajas').onValue.map((event) {
      if (event.snapshot.value == null) return {};
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      LocalStorageService.guardarCajas(sucursalId, data);
      return data;
    });
  }

  // Obtiene el grafo de navegación de una sucursal
  Future<Map<dynamic, dynamic>> obtenerGrafo(String sucursalId) async {
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

    // Fallback: intentar de caché
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