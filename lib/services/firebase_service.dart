import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/producto.dart';
import '../models/nodo_grafo.dart';
import 'local_storage_service.dart';
import '../services/firebase_service.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ---------------------------------------------------------------------
  // Caché en memoria de TODOS los productos. Antes, cada búsqueda (cada
  // letra escrita, en el Home, en el diálogo de peso, donde sea) volvía a
  // traer los 55 productos de Firebase Y a reescribirlos uno por uno en
  // Hive — de ahí la lentitud. Ahora se trae una sola vez y se reutiliza
  // desde memoria hasta que expire (o hasta que se llame precargarProductos
  // otra vez). No cambia el respaldo offline: si no hay conexión, sigue
  // cayendo en Hive exactamente igual que antes.
  static List<Producto>? _cacheProductos;
  static DateTime? _cacheTimestamp;
  static const Duration _duracionCache = Duration(minutes: 10);
  static const List<String> _palabrasVacias = [
    'de', 'la', 'el', 'los', 'las', 'un', 'una', 'para', 'que', 'se',
    'y', 'o', 'con', 'sin', 'del', 'al', 'a',
  ];

  bool get _cacheValida =>
      _cacheProductos != null &&
          _cacheTimestamp != null &&
          DateTime.now().difference(_cacheTimestamp!) < _duracionCache;

  Future<bool> _hayConexion() async {
    final resultados = await Connectivity().checkConnectivity();
    return !resultados.contains(ConnectivityResult.none);
  }

  // Quita tildes y pasa a minúsculas, para comparar texto sin que las tildes bloqueen la búsqueda
  String _normalizar(String texto) {
    const conTilde = 'áéíóúÁÉÍÓÚñÑ';
    const sinTilde = 'aeiouAEIOUnN';
    var resultado = texto.toLowerCase();
    for (int i = 0; i < conTilde.length; i++) {
      resultado = resultado.replaceAll(conTilde[i], sinTilde[i].toLowerCase());
    }
    return resultado;
  }



  // Genera las variantes de código a probar: el código real (físico/escaneado) no trae
  // la "A" que sirena.do usa como prefijo de PLU en la base de datos
  List<String> _variantesCodigo(String codigo) {
    final limpio = codigo.trim();
    if (limpio.toUpperCase().startsWith('A')) {
      return [limpio, limpio.substring(1)];
    }
    return [limpio, 'A$limpio'];
  }

  /// Llama esto UNA vez al arrancar la app (main.dart, después de
  /// inicializar Firebase) para que la caché ya esté lista antes de que
  /// el usuario escriba su primera búsqueda. No es obligatorio — si no se
  /// llama, la caché se llena sola en la primera búsqueda igual — pero
  /// llamarlo al inicio evita que esa primera búsqueda se sienta lenta.
  Future<void> precargarProductos() async {
    await _obtenerTodosLosProductos();
  }

  /// Trae todos los productos, usando la caché en memoria cuando está
  /// vigente. Si no hay caché válida: intenta Firebase (y de paso
  /// actualiza Hive), y si eso falla o no hay conexión, cae a Hive.
  Future<List<Producto>> _obtenerTodosLosProductos() async {
    if (_cacheValida) return _cacheProductos!;

    if (await _hayConexion()) {
      try {
        final snapshot = await _db.child('productos').get().timeout(const Duration(seconds: 2));
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          final productos = <Producto>[];
          for (var entry in data.entries) {
            final codigo = entry.key;
            final valor = entry.value as Map<dynamic, dynamic>;
            await LocalStorageService.guardarProducto(codigo, valor);
            productos.add(Producto.fromMap(codigo, valor));
          }
          _cacheProductos = productos;
          _cacheTimestamp = DateTime.now();
          return productos;
        }
      } catch (e) {
        print('Error obteniendo productos de Firebase: $e');
      }
    }

    // Sin conexión o falló: usar lo que haya en Hive, y guardarlo también
    // como caché en memoria para no repetir la lectura de Hive en cada
    // búsqueda mientras se siga sin conexión.
    final cachedData = LocalStorageService.obtenerTodosLosProductos();
    final productos = cachedData.map((data) {
      final codigo = data['codigo_barra'] ?? '';
      return Producto.fromMap(codigo, data);
    }).toList();
    if (productos.isNotEmpty) {
      _cacheProductos = productos;
      _cacheTimestamp = DateTime.now();
    }
    return productos;
  }

  // Busca un producto exacto por su código de barras/PLU
  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    final variantes = _variantesCodigo(codigo);

    // Primero revisa la caché en memoria, si ya está cargada
    if (_cacheValida) {
      for (final variante in variantes) {
        final coincidencias = _cacheProductos!.where((p) => p.codigoBarra == variante);
        if (coincidencias.isNotEmpty) return coincidencias.first;
      }
    }

    if (await _hayConexion()) {
      for (final variante in variantes) {
        try {
          final snapshot = await _db.child('productos/$variante').get().timeout(const Duration(seconds: 2));
          if (snapshot.exists) {
            final data = snapshot.value as Map<dynamic, dynamic>;
            await LocalStorageService.guardarProducto(variante, data);
            return Producto.fromMap(variante, data);
          }
        } catch (e) {
          print('Error obteniendo producto de Firebase: $e');
        }
      }
    }

    // Sin conexión o no encontrado: probar las mismas variantes en la caché
    for (final variante in variantes) {
      final cachedData = LocalStorageService.obtenerProducto(variante);
      if (cachedData != null) {
        return Producto.fromMap(variante, cachedData);
      }
    }
    return null;
  }

  // Busca productos por nombre (para los de peso variable, sin código escaneable)
  // Busca productos por nombre (para los de peso variable, sin código escaneable)
  Future<List<Producto>> buscarProductosPorNombre(String query) async {
    final queryNormalizada = _normalizar(query);
    final todos = await _obtenerTodosLosProductos();

    if (queryNormalizada.trim().isEmpty) return todos;

    // Divide la búsqueda en palabras sueltas y exige que TODAS aparezcan
    // en el nombre del producto (en cualquier orden) — así "pan de viga"
    // sí encuentra "Pan Blanco Wala Viga" aunque no sea substring exacto.
    final palabras = queryNormalizada
        .split(' ')
        .where((p) => p.isNotEmpty && !_palabrasVacias.contains(p))
        .toList();

    return todos.where((producto) {
      final nombreNormalizado = _normalizar(producto.nombre);
      return palabras.every((palabra) => nombreNormalizado.contains(palabra));
    }).toList();
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

  // Guarda una valoración del chat de IA en Firebase (estadísticas para Grupo Ramos)
  Future<void> guardarValoracionChat(Map<String, dynamic> datos) async {
    try {
      await _db.child('valoraciones_chat').push().set(datos);
    } catch (e) {
      print('Error guardando valoración de chat: $e');
    }
  }
}