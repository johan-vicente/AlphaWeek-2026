import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

// Script de un solo uso: asigna a cada producto 2 o 3 de las 3 sucursales al azar,
// para que "Disponibilidad en sucursales" se vea real en la demo (nunca 0, nunca siempre las 3)
Future<void> actualizarSucursalesProductos() async {
  final db = FirebaseDatabase.instance.ref();
  final random = Random();
  const sucursalesDisponibles = ['villa_mella', 'las_americas', 'autopista_san_isidro'];

  final snapshot = await db.child('productos').get();
  if (!snapshot.exists) {
    print('No se encontraron productos.');
    return;
  }

  final productos = snapshot.value as Map<dynamic, dynamic>;
  final Map<String, dynamic> actualizaciones = {};

  for (final codigo in productos.keys) {
    final cantidad = 2 + random.nextInt(2); // 2 o 3 sucursales
    final sucursalesProducto = (List<String>.from(sucursalesDisponibles)..shuffle(random))
        .take(cantidad)
        .toList();
    actualizaciones['productos/$codigo/sucursales'] = sucursalesProducto;
  }

  await db.update(actualizaciones);
  print('Sucursales actualizadas para ${productos.length} productos.');
}