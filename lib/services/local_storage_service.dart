import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String productosBoxName = 'productos_box';
  static const String grafosBoxName = 'grafos_box';
  static const String cajasBoxName = 'cajas_box';

  /// Inicializa Hive y abre las cajas de almacenamiento
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(productosBoxName);
    await Hive.openBox(grafosBoxName);
    await Hive.openBox(cajasBoxName);
  }

  // --- Productos ---
  static Future<void> guardarProducto(String codigo, Map<dynamic, dynamic> data) async {
    final box = Hive.box(productosBoxName);
    await box.put(codigo, data);
  }

  static Map<dynamic, dynamic>? obtenerProducto(String codigo) {
    final box = Hive.box(productosBoxName);
    final data = box.get(codigo);
    if (data == null) return null;
    // Hive a veces devuelve _Map<dynamic, dynamic>, forzamos casteo seguro
    return Map<dynamic, dynamic>.from(data);
  }

  static List<Map<dynamic, dynamic>> obtenerTodosLosProductos() {
    final box = Hive.box(productosBoxName);
    return box.values.map((e) => Map<dynamic, dynamic>.from(e)).toList();
  }

  // --- Grafos ---
  static Future<void> guardarGrafo(String sucursalId, Map<dynamic, dynamic> data) async {
    final box = Hive.box(grafosBoxName);
    await box.put(sucursalId, data);
  }

  static Map<dynamic, dynamic>? obtenerGrafo(String sucursalId) {
    final box = Hive.box(grafosBoxName);
    final data = box.get(sucursalId);
    if (data == null) return null;
    return Map<dynamic, dynamic>.from(data);
  }

  // --- Cajas ---
  static Future<void> guardarCajas(String sucursalId, Map<dynamic, dynamic> data) async {
    final box = Hive.box(cajasBoxName);
    await box.put(sucursalId, data);
  }

  static Map<dynamic, dynamic>? obtenerCajas(String sucursalId) {
    final box = Hive.box(cajasBoxName);
    final data = box.get(sucursalId);
    if (data == null) return null;
    return Map<dynamic, dynamic>.from(data);
  }
}
