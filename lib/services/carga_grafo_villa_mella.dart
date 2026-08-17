import 'package:firebase_database/firebase_database.dart';

/// Script de un solo uso: carga el grafo de Villa Mella.
/// Tercera y última sucursal — mismo criterio rápido que Las Américas
/// (sin etiquetas de texto, calibración razonable pero no al extremo).
///
/// Layout real: 8 cajas (1 y 5 deshabilitadas). 18 pasillos — fila de
/// arriba 1,2,3,[Electrodomésticos],4,5,6,7 (el 3 y el 5 no tienen barra
/// dibujada en el mockup, solo el número — se interpolan). Fila de abajo
/// 18,17,...,9,8 secuencial de izquierda a derecha (el 8, pegado al borde
/// de Congelados, tampoco tiene barra — se interpola). Carnes/Embutidos
/// en la franja izquierda completa (como Congelados en la derecha).
/// Hortalizas cerca del fondo, entre los pasillos de abajo. Panadería
/// abajo-izquierda, Lácteos/Jugos abajo-centro-derecha.
Future<void> cargarGrafoVillaMella() async {
  final dbGrafo = FirebaseDatabase.instance.ref('sucursales/villa_mella/grafo/nodos');

  final nodos = <String, Map<String, dynamic>>{
    'entrada': {'tipo': 'entrada', 'x': 0.92, 'y': 0.04, 'conexiones': ['corredor_superior']},
    'salida': {'tipo': 'salida', 'x': 0.06, 'y': 0.04, 'conexiones': ['corredor_superior']},

    'caja1': {'tipo': 'caja', 'x': 0.232, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja2': {'tipo': 'caja', 'x': 0.310, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja3': {'tipo': 'caja', 'x': 0.388, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja4': {'tipo': 'caja', 'x': 0.466, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja5': {'tipo': 'caja', 'x': 0.543, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja6': {'tipo': 'caja', 'x': 0.621, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja7': {'tipo': 'caja', 'x': 0.699, 'y': 0.114, 'conexiones': ['corredor_superior']},
    'caja8': {'tipo': 'caja', 'x': 0.777, 'y': 0.114, 'conexiones': ['corredor_superior']},

    'corredor_superior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.145,
      'conexiones': [
        'entrada', 'salida', 'caja1', 'caja2', 'caja3', 'caja4', 'caja5', 'caja6', 'caja7', 'caja8',
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6', 'pasillo7',
        'zona_electrodomesticos', 'zona_carnes', 'zona_embutidos', 'zona_congelados',
        'corredor_central',
      ]
    },

    // Fila de arriba (1,2,3 a la izquierda del cajón de Electrodomésticos, 4-7 a la derecha)
    'pasillo1': {'tipo': 'pasillo', 'x': 0.146, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo2': {'tipo': 'pasillo', 'x': 0.231, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo3': {'tipo': 'pasillo', 'x': 0.317, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']}, // interpolado, sin barra visible
    'pasillo4': {'tipo': 'pasillo', 'x': 0.702, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo5': {'tipo': 'pasillo', 'x': 0.741, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']}, // interpolado, sin barra visible
    'pasillo6': {'tipo': 'pasillo', 'x': 0.780, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'pasillo7': {'tipo': 'pasillo', 'x': 0.855, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},

    'corredor_central': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.49,
      'conexiones': [
        'pasillo1', 'pasillo2', 'pasillo3', 'pasillo4', 'pasillo5', 'pasillo6', 'pasillo7',
        'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14',
        'pasillo15', 'pasillo16', 'pasillo17', 'pasillo18',
        'zona_electrodomesticos',
        'corredor_superior', 'corredor_inferior',
      ]
    },

    // Fila de abajo, secuencial 18 -> 8 de izquierda a derecha
    'pasillo18': {'tipo': 'pasillo', 'x': 0.153, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo17': {'tipo': 'pasillo', 'x': 0.231, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo16': {'tipo': 'pasillo', 'x': 0.309, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo15': {'tipo': 'pasillo', 'x': 0.386, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo14': {'tipo': 'pasillo', 'x': 0.466, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo13': {'tipo': 'pasillo', 'x': 0.543, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo12': {'tipo': 'pasillo', 'x': 0.621, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo11': {'tipo': 'pasillo', 'x': 0.699, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo10': {'tipo': 'pasillo', 'x': 0.777, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo9': {'tipo': 'pasillo', 'x': 0.856, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']},
    'pasillo8': {'tipo': 'pasillo', 'x': 0.935, 'y': 0.66, 'conexiones': ['corredor_central', 'corredor_inferior']}, // interpolado, sin barra visible

    'corredor_inferior': {
      'tipo': 'interseccion', 'x': 0.5, 'y': 0.85,
      'conexiones': [
        'pasillo8', 'pasillo9', 'pasillo10', 'pasillo11', 'pasillo12', 'pasillo13', 'pasillo14',
        'pasillo15', 'pasillo16', 'pasillo17', 'pasillo18',
        'zona_carnes', 'zona_embutidos', 'zona_congelados', 'zona_hortalizas',
        'zona_panaderia', 'zona_lacteos', 'zona_jugos',
        'corredor_central',
      ]
    },

    'zona_electrodomesticos': {'tipo': 'zona', 'x': 0.510, 'y': 0.320, 'conexiones': ['corredor_superior', 'corredor_central']},
    'zona_carnes': {'tipo': 'zona', 'x': 0.041, 'y': 0.68, 'conexiones': ['corredor_superior', 'corredor_inferior']},
    'zona_embutidos': {'tipo': 'zona', 'x': 0.041, 'y': 0.87, 'conexiones': ['corredor_superior', 'corredor_inferior']},
    'zona_congelados': {'tipo': 'zona', 'x': 0.965, 'y': 0.80, 'conexiones': ['corredor_superior', 'corredor_inferior']},
    'zona_hortalizas': {'tipo': 'zona', 'x': 0.683, 'y': 0.890, 'conexiones': ['corredor_inferior']},
    'zona_panaderia': {'tipo': 'zona', 'x': 0.222, 'y': 0.955, 'conexiones': ['corredor_inferior']},
    'zona_lacteos': {'tipo': 'zona', 'x': 0.526, 'y': 0.961, 'conexiones': ['corredor_inferior']},
    'zona_jugos': {'tipo': 'zona', 'x': 0.785, 'y': 0.961, 'conexiones': ['corredor_inferior']},
  };

  await dbGrafo.set(nodos);
  // ignore: avoid_print
  print('Grafo de Villa Mella cargado: ${nodos.length} nodos');

  final dbCajas = FirebaseDatabase.instance.ref('sucursales/villa_mella/cajas');
  await dbCajas.set({
    'caja1': {'nombre': 'Caja 1', 'habilitada': false},
    'caja2': {'nombre': 'Caja 2', 'habilitada': true},
    'caja3': {'nombre': 'Caja 3', 'habilitada': true},
    'caja4': {'nombre': 'Caja 4', 'habilitada': true},
    'caja5': {'nombre': 'Caja 5', 'habilitada': false},
    'caja6': {'nombre': 'Caja 6', 'habilitada': true},
    'caja7': {'nombre': 'Caja 7', 'habilitada': true},
    'caja8': {'nombre': 'Caja 8', 'habilitada': true},
  });
  // ignore: avoid_print
  print('Cajas de Villa Mella actualizadas según el mockup');
}