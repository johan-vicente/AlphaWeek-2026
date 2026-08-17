import 'package:firebase_database/firebase_database.dart';

/// Script de un solo uso: carga el grafo de Las Américas.
/// Sucursal secundaria (no se presenta en la demo, pero queda funcional
/// por si se quiere mostrar) — menos calibrado a pixel que San Isidro,
/// a propósito.
///
/// Layout real: 16 pasillos — fila de arriba numerada 6,7,5,4,3,2,1 (no
/// secuencial, izquierda a derecha), fila de abajo 8-16 (secuencial).
/// Electrodomésticos arriba-derecha. Congelados franja izquierda completa.
/// Hortalizas abajo (NO arriba-derecha como en San Isidro). Panadería,
/// Lácteos, Jugos en la franja derecha. Carnes/Embutidos abajo.
Future<void> cargarGrafoLasAmericas() async {
  final dbGrafo = FirebaseDatabase.instance.ref('sucursales/las_americas/grafo/nodos');

  final nodos = <String, Map<String, dynamic>>{
    'entrada': {'tipo': 'entrada', 'x': 0.92, 'y': 0.04, 'conexiones': ['corredor_superior']},
    'salida': {'tipo': 'salida', 'x': 0.06, 'y': 0.04, 'conexiones': ['corredor_superior']},

    'caja1': {'tipo': 'caja', 'x': 0.198, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja2': {'tipo': 'caja', 'x': 0.304, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja3': {'tipo': 'caja', 'x': 0.411, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja4': {'tipo': 'caja', 'x': 0.517, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja5': {'tipo': 'caja', 'x': 0.624, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja6': {'tipo': 'caja', 'x': 0.730, 'y': 0.109, 'conexiones': ['corredor_superior']},
    'caja7': {'tipo': 'caja', 'x': 0.837, 'y': 0.109, 'conexiones': ['corredor_superior']},

    'corredor_superior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.145,
      'conexiones': [
        'entrada', 'salida', 'caja1', 'caja2', 'caja3', 'caja4', 'caja5', 'caja6', 'caja7',
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6', 'pasillo7',
        'zona_electrodomesticos', 'zona_congelados',
        'corredor_central',
      ]
    },

    // Fila de arriba, numeración real 6,7,5,4,3,2,1 de izquierda a derecha
    'pasillo6': {'tipo': 'pasillo', 'x': 0.114, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo7': {'tipo': 'pasillo', 'x': 0.195, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo5': {'tipo': 'pasillo', 'x': 0.277, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo4': {'tipo': 'pasillo', 'x': 0.353, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo3': {'tipo': 'pasillo', 'x': 0.429, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo2': {'tipo': 'pasillo', 'x': 0.502, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo1': {'tipo': 'pasillo', 'x': 0.576, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},

    'corredor_central': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.49,
      'conexiones': [
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6', 'pasillo7',
        'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14', 'pasillo15', 'pasillo16',
        'zona_lacteos',
        'corredor_superior', 'corredor_inferior',
      ]
    },

    // Fila de abajo, secuencial 8-16
    'pasillo8': {'tipo': 'pasillo', 'x': 0.196, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo9': {'tipo': 'pasillo', 'x': 0.279, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo10': {'tipo': 'pasillo', 'x': 0.354, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo11': {'tipo': 'pasillo', 'x': 0.429, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo12': {'tipo': 'pasillo', 'x': 0.502, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo13': {'tipo': 'pasillo', 'x': 0.577, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo14': {'tipo': 'pasillo', 'x': 0.655, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo15': {'tipo': 'pasillo', 'x': 0.733, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo16': {'tipo': 'pasillo', 'x': 0.813, 'y': 0.657, 'conexiones': ['corredor_central', 'corredor_inferior']},

    'corredor_inferior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.82,
      'conexiones': [
        'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14', 'pasillo15', 'pasillo16',
        'zona_congelados', 'zona_hortalizas', 'zona_panaderia', 'zona_jugos', 'zona_carnes', 'zona_embutidos',
        'corredor_central',
      ]
    },

    'zona_electrodomesticos': {'tipo': 'zona', 'x': 0.79, 'y': 0.30, 'conexiones': ['corredor_superior', 'corredor_central']},
    'zona_congelados': {'tipo': 'zona', 'x': 0.03, 'y': 0.80, 'conexiones': ['corredor_superior', 'corredor_inferior']},
    'zona_hortalizas': {'tipo': 'zona', 'x': 0.307, 'y': 0.874, 'conexiones': ['corredor_inferior']},
    'zona_panaderia': {'tipo': 'zona', 'x': 0.746, 'y': 0.900, 'conexiones': ['corredor_inferior']},
    'zona_lacteos': {'tipo': 'zona', 'x': 0.933, 'y': 0.581, 'conexiones': ['corredor_central']},
    'zona_jugos': {'tipo': 'zona', 'x': 0.947, 'y': 0.759, 'conexiones': ['corredor_inferior']},
    'zona_carnes': {'tipo': 'zona', 'x': 0.157, 'y': 0.972, 'conexiones': ['corredor_inferior']},
    'zona_embutidos': {'tipo': 'zona', 'x': 0.416, 'y': 0.972, 'conexiones': ['corredor_inferior']},
  };

  await dbGrafo.set(nodos);
  // ignore: avoid_print
  print('Grafo de Las Américas cargado: ${nodos.length} nodos');

  final dbCajas = FirebaseDatabase.instance.ref('sucursales/las_americas/cajas');
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
  print('Cajas de Las Américas actualizadas según el mockup');
}