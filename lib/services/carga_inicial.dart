import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';

Future<void> cargarProductosDesdeAssets() async {
  final String jsonString = await rootBundle.loadString('assets/data/productos_demo.json');
  final Map<String, dynamic> data = json.decode(jsonString);
  final List<dynamic> productos = data['productos'];

  final db = FirebaseDatabase.instance.ref();
  int cargados = 0;
  int saltados = 0;

  for (final p in productos) {
    final codigo = p['codigo_barra'];
    if (codigo == null) {
      saltados++;
      continue; // salta "Ajo Selecto", que aún no tiene código
    }
    await db.child('productos/$codigo').set(p);
    cargados++;
  }

  print('Carga completa: $cargados productos cargados, $saltados saltados por falta de código.');
}

Future<void> cargarGrafoDesdeAssets() async {
  final String jsonString = await rootBundle.loadString('assets/data/grafo_sucursales.json');
  final Map<String, dynamic> data = json.decode(jsonString);
  final Map<String, dynamic> sucursales = data['sucursales'];

  final db = FirebaseDatabase.instance.ref();

  for (final entry in sucursales.entries) {
    final sucursalId = entry.key;
    final nodos = entry.value['nodos'];
    await db.child('sucursales/$sucursalId/grafo/nodos').set(nodos);
    print('Grafo cargado para: $sucursalId');
  }
}

Future<void> cargarCajasDesdeAssets() async {
  final db = FirebaseDatabase.instance.ref();
  final sucursales = ['villa_mella', 'las_americas', 'autopista_san_isidro'];

  for (final sucursalId in sucursales) {
    final Map<String, dynamic> cajas = {};
    for (int i = 1; i <= 7; i++) {
      cajas['caja_$i'] = {
        'nombre': 'Caja $i',
        'habilitada': i % 2 != 0, // alterna abierta/cerrada para la demo, ajustable
      };
    }
    await db.child('sucursales/$sucursalId/cajas').set(cajas);
    print('Cajas cargadas para: $sucursalId');
  }
}