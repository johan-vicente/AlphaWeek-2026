import 'package:firebase_database/firebase_database.dart';

/// Script de un solo uso: carga los productos faltantes para que Sira
/// pueda armar una lista completa de sancocho dominicano.
/// Datos verificados directo de sirena.do (PLU, imagen y categoría reales).
Future<void> cargarProductosSancocho() async {
  final db = FirebaseDatabase.instance.ref('productos');

  const todasLasSucursales = ['villa_mella', 'autopista_san_isidro', 'las_americas'];

  final productos = <String, Map<String, dynamic>>{
    // --- Condimentos ---
    'A6954821584253': {
      'codigo_barra': 'A6954821584253',
      'nombre': 'Ajo Selecto Paquete 4 Uds',
      'tipo_venta': 'empacado',
      'precio': 60,
      'categoria': 'Frutas y Vegetales / Vegetales Frescos',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/161919-800-800?v=639096165754200000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A2100003188489': {
      'codigo_barra': 'A2100003188489',
      'nombre': 'Oregano Molido Wala 90 G',
      'tipo_venta': 'empacado',
      'precio': 99,
      'categoria': 'Despensa / Especias y Condimentos',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/168184-800-800?v=639119916765670000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A2100003198181': {
      'codigo_barra': 'A2100003198181',
      'nombre': 'Sazon Completo En Polvo Wala 8 Oz',
      'tipo_venta': 'empacado',
      'precio': 49,
      'categoria': 'Despensa / Especias y Condimentos',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/159507-800-800?v=639087835014200000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A2100002986895': {
      'codigo_barra': 'A2100002986895',
      'nombre': 'Sal Refinada Frasco 432 Wala Gr',
      'tipo_venta': 'empacado',
      'precio': 39,
      'categoria': 'Despensa / Especias y Condimentos',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/169293-800-800?v=639120837065030000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A2100003032201': {
      'codigo_barra': 'A2100003032201',
      'nombre': 'Vinagre Blanco Wala 16 Oz',
      'tipo_venta': 'empacado',
      'precio': 25,
      'categoria': 'Despensa / Aderezos y Salsas',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/165434-800-800?v=639105870561970000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A7468827171465': {
      'codigo_barra': 'A7468827171465',
      'nombre': 'Cilantro Ancho Por Paquete',
      'tipo_venta': 'empacado',
      'precio': 48,
      'categoria': 'Frutas y Vegetales / Vegetales Frescos',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/164302-800-800?v=639102525069270000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },

    // --- Víveres ---
    '02296': {
      'codigo_barra': '02296',
      'nombre': 'Yuca Parafinada Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 37,
      'categoria': 'Frutas y Vegetales / Víveres',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175029-800-800?v=639154032060170000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    '01007': {
      'codigo_barra': '01007',
      'nombre': 'Ñame Fresco Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 89,
      'categoria': 'Frutas y Vegetales / Víveres',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175039-800-800?v=639154038033130000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    '01010': {
      'codigo_barra': '01010',
      'nombre': 'Yautia Blanca Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 77,
      'categoria': 'Frutas y Vegetales / Víveres',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175043-800-800?v=639154041027400000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    '02012': {
      'codigo_barra': '02012',
      'nombre': 'Auyama Criolla Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 29,
      'categoria': 'Frutas y Vegetales / Víveres',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175045-800-800?v=639154041039700000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    '01002': {
      'codigo_barra': '01002',
      'nombre': 'Batata Fresca Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 27,
      'categoria': 'Frutas y Vegetales / Víveres',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175060-800-800?v=639154047066370000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },

    // --- Carnes ---
    '06003': {
      'codigo_barra': '06003',
      'nombre': 'Filete De Pechuga Pollo Cibao Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 179,
      'categoria': 'Carnes, Pescados y Mariscos / Carne de Pollo',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/176018-800-800?v=639172251046200000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    '05044': {
      'codigo_barra': '05044',
      'nombre': 'Chuleta De Cerdo Ahumada Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 127,
      'categoria': 'Carnes, Pescados y Mariscos / Carne de Cerdo',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/157049-800-800?v=639065958019630000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },

    // --- Extras (mandarina, aguacate) ---
    'A1735030': {
      'codigo_barra': 'A1735030',
      'nombre': 'Mandarina Importada Lb',
      'tipo_venta': 'peso_variable',
      'precio_por_libra': 99,
      'categoria': 'Frutas y Vegetales / Frutas Frescas',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/165515-800-800?v=639105939006700000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
    'A00003': {
      'codigo_barra': 'A00003',
      'nombre': 'Aguacate 35% Maduro Und',
      'tipo_venta': 'empacado',
      'precio': 54,
      'categoria': 'Frutas y Vegetales / Frutas Frescas',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/175057-800-800?v=639154047047570000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },

    'A2100003356987': {
      'codigo_barra': 'A2100003356987',
      'nombre': 'Papas Fritas con Limon Wala 55 Gr',
      'tipo_venta': 'empacado',
      'precio': 65,
      'categoria': 'Picadera / Papitas y Chips',
      'imagen_url':
      'https://gruporamos.vtexassets.com/arquivos/ids/177623-800-800?v=639203445701630000&width=800&height=800&aspect=true',
      'sucursales': todasLasSucursales,
    },
  };

  await db.update(productos);
  // ignore: avoid_print
  print('Productos de sancocho cargados: ${productos.length}');
}