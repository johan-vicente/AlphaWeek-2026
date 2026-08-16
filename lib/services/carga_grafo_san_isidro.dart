import 'package:firebase_database/firebase_database.dart';

/// Script de un solo uso: carga el grafo real de San Isidro.
///
/// v5: Entrada/Salida un poco más separadas hacia sus esquinas (Salida más
/// a la izquierda, Entrada más a la derecha). Todo lo demás igual que v4.
Future<void> cargarGrafoSanIsidro() async {
  final dbGrafo = FirebaseDatabase.instance.ref('sucursales/autopista_san_isidro/grafo/nodos');

  final nodos = <String, Map<String, dynamic>>{
    'entrada': {'tipo': 'entrada', 'x': 0.950, 'y': 0.048, 'conexiones': ['corredor_superior']},
    'salida': {'tipo': 'salida', 'x': 0.055, 'y': 0.048, 'conexiones': ['corredor_superior']},

    'caja1': {'tipo': 'caja', 'x': 0.225, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja2': {'tipo': 'caja', 'x': 0.325, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja3': {'tipo': 'caja', 'x': 0.425, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja4': {'tipo': 'caja', 'x': 0.525, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja5': {'tipo': 'caja', 'x': 0.625, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja6': {'tipo': 'caja', 'x': 0.725, 'y': 0.142, 'conexiones': ['corredor_superior']},
    'caja7': {'tipo': 'caja', 'x': 0.825, 'y': 0.142, 'conexiones': ['corredor_superior']},

    'corredor_superior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.195,
      'conexiones': [
        'entrada', 'salida', 'caja1', 'caja2', 'caja3', 'caja4', 'caja5', 'caja6', 'caja7',
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6',
        'zona_electrodomesticos', 'zona_hortalizas', 'zona_congelados',
        'corredor_central',
      ]
    },

    'pasillo1': {'tipo': 'pasillo', 'x': 0.399, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo2': {'tipo': 'pasillo', 'x': 0.492, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo3': {'tipo': 'pasillo', 'x': 0.578, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo4': {'tipo': 'pasillo', 'x': 0.665, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo5': {'tipo': 'pasillo', 'x': 0.751, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo6': {'tipo': 'pasillo', 'x': 0.842, 'y': 0.378, 'conexiones': ['corredor_superior', 'corredor_central']},

    'corredor_central': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.60,
      'conexiones': [
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6',
        'pasillo7', 'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14', 'pasillo15',
        'zona_electrodomesticos', 'zona_hortalizas',
        'corredor_superior', 'corredor_inferior',
      ]
    },

    'pasillo7': {'tipo': 'pasillo', 'x': 0.850, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo8': {'tipo': 'pasillo', 'x': 0.760, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo9': {'tipo': 'pasillo', 'x': 0.673, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo10': {'tipo': 'pasillo', 'x': 0.589, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo11': {'tipo': 'pasillo', 'x': 0.491, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo12': {'tipo': 'pasillo', 'x': 0.398, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo13': {'tipo': 'pasillo', 'x': 0.297, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo14': {'tipo': 'pasillo', 'x': 0.196, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo15': {'tipo': 'pasillo', 'x': 0.106, 'y': 0.718, 'conexiones': ['corredor_central', 'corredor_inferior']},

    'corredor_inferior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.90,
      'conexiones': [
        'pasillo7', 'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14', 'pasillo15',
        'zona_congelados', 'zona_panaderia', 'zona_lacteos', 'zona_carnes', 'zona_jugos', 'zona_embutidos',
        'corredor_central',
      ]
    },

    'zona_electrodomesticos': {'tipo': 'zona', 'x': 0.226, 'y': 0.346, 'conexiones': ['corredor_superior', 'corredor_central']},
    'zona_hortalizas': {'tipo': 'zona', 'x': 0.947, 'y': 0.388, 'conexiones': ['corredor_superior', 'corredor_central']},
    'zona_congelados': {'tipo': 'zona', 'x': 0.035, 'y': 0.82, 'conexiones': ['corredor_superior', 'corredor_inferior']},
    'zona_panaderia': {'tipo': 'zona', 'x': 0.947, 'y': 0.666, 'conexiones': ['corredor_inferior']},
    'zona_lacteos': {'tipo': 'zona', 'x': 0.947, 'y': 0.873, 'conexiones': ['corredor_inferior']},

    'zona_carnes': {'tipo': 'zona', 'x': 0.169, 'y': 0.961, 'conexiones': ['corredor_inferior']},
    'zona_jugos': {'tipo': 'zona', 'x': 0.476, 'y': 0.961, 'conexiones': ['corredor_inferior']},
    'zona_embutidos': {'tipo': 'zona', 'x': 0.749, 'y': 0.961, 'conexiones': ['corredor_inferior']},
  };

  await dbGrafo.set(nodos);
  // ignore: avoid_print
  print('Grafo de San Isidro cargado: ${nodos.length} nodos');

  final dbCajas = FirebaseDatabase.instance.ref('sucursales/autopista_san_isidro/cajas');
  await dbCajas.set({
    'caja1': {'nombre': 'Caja 1', 'habilitada': false},
    'caja2': {'nombre': 'Caja 2', 'habilitada': true},
    'caja3': {'nombre': 'Caja 3', 'habilitada': true},
    'caja4': {'nombre': 'Caja 4', 'habilitada': true},
    'caja5': {'nombre': 'Caja 5', 'habilitada': true},
    'caja6': {'nombre': 'Caja 6', 'habilitada': true},
    'caja7': {'nombre': 'Caja 7', 'habilitada': true},
  });
  // ignore: avoid_print
  print('Cajas de San Isidro actualizadas según el mockup');
}