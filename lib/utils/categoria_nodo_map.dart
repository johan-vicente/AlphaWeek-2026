import 'package:flutter/material.dart';

/// Mapeo de categoría de producto -> nodo del grafo, por sucursal.
class CategoriaNodoMap {
  // Mapeo fino por subcategoría exacta ("Categoría / Subcategoría").
  static const Map<String, Map<String, String>> _mapaExactoPorSucursal = {
    'autopista_san_isidro': {
      'Despensa / Aceites': 'pasillo1',
      'Despensa / Arroz': 'pasillo2',
      'Despensa / Azúcar': 'pasillo3',
      'Despensa / Café': 'pasillo4',
      'Limpieza y Desechables / Cloros y Desinfectantes': 'pasillo5',
      'Limpieza y Desechables / Cuidado de la Ropa': 'pasillo6',
      'Limpieza y Desechables / Desechables': 'pasillo7',
      'Limpieza y Desechables / Papel toalla y servilletas': 'pasillo8',
      'Galletas y Dulces / Chocolates': 'pasillo9',
      'Galletas y Dulces / Galletas': 'pasillo10',
      'Galletas y Dulces / Galletas Sodas': 'pasillo11',
      'Vinos, licores y cervezas / Cervezas': 'pasillo12',
      'Bebé / Toallas Húmedas': 'pasillo13',
    },
    'las_americas': {
      'Despensa / Aceites': 'pasillo1',
      'Despensa / Arroz': 'pasillo2',
      'Despensa / Azúcar': 'pasillo3',
      'Despensa / Café': 'pasillo4',
      'Limpieza y Desechables / Cloros y Desinfectantes': 'pasillo5',
      'Limpieza y Desechables / Cuidado de la Ropa': 'pasillo6',
      'Limpieza y Desechables / Desechables': 'pasillo7',
      'Limpieza y Desechables / Papel toalla y servilletas': 'pasillo8',
      'Galletas y Dulces / Chocolates': 'pasillo9',
      'Galletas y Dulces / Galletas': 'pasillo10',
      'Galletas y Dulces / Galletas Sodas': 'pasillo11',
      'Vinos, licores y cervezas / Cervezas': 'pasillo12',
      'Bebé / Toallas Húmedas': 'pasillo13',
      'Listo para Comer / Sándwich': 'pasillo14',
    },
    // Villa Mella: mismo criterio, sin texto visible en el mapa (solo lo
    // usa el buscador). También tiene "Listo para Comer" en su catálogo.
    'villa_mella': {
      'Despensa / Aceites': 'pasillo1',
      'Despensa / Arroz': 'pasillo2',
      'Despensa / Azúcar': 'pasillo3',
      'Despensa / Café': 'pasillo4',
      'Limpieza y Desechables / Cloros y Desinfectantes': 'pasillo5',
      'Limpieza y Desechables / Cuidado de la Ropa': 'pasillo6',
      'Limpieza y Desechables / Desechables': 'pasillo7',
      'Limpieza y Desechables / Papel toalla y servilletas': 'pasillo8',
      'Galletas y Dulces / Chocolates': 'pasillo9',
      'Galletas y Dulces / Galletas': 'pasillo10',
      'Galletas y Dulces / Galletas Sodas': 'pasillo11',
      'Vinos, licores y cervezas / Cervezas': 'pasillo12',
      'Bebé / Toallas Húmedas': 'pasillo13',
      'Listo para Comer / Sándwich': 'pasillo14',
    },
  };

  // Mapeo por categoría raíz (fallback, y lo que usan las categorías que
  // van a una zona real del mapa en vez de a un pasillo numérico).
  static const Map<String, Map<String, String>> _mapaRaizPorSucursal = {
    'autopista_san_isidro': {
      'Frutas y Vegetales': 'zona_hortalizas',
      'Lácteos y Huevos': 'zona_lacteos',
      'Panadería y Repostería': 'zona_panaderia',
      'Quesos y Embutidos': 'zona_embutidos',
      'Despensa': 'pasillo1',
      'Limpieza y Desechables': 'pasillo5',
      'Galletas y Dulces': 'pasillo10',
      'Vinos, licores y cervezas': 'pasillo12',
      'Bebé': 'pasillo13',
    },
    'las_americas': {
      'Frutas y Vegetales': 'zona_hortalizas',
      'Lácteos y Huevos': 'zona_lacteos',
      'Panadería y Repostería': 'zona_panaderia',
      'Quesos y Embutidos': 'zona_embutidos',
      'Despensa': 'pasillo1',
      'Limpieza y Desechables': 'pasillo5',
      'Galletas y Dulces': 'pasillo10',
      'Vinos, licores y cervezas': 'pasillo12',
      'Bebé': 'pasillo13',
      'Listo para Comer': 'pasillo14',
    },
    'villa_mella': {
      'Frutas y Vegetales': 'zona_hortalizas',
      'Lácteos y Huevos': 'zona_lacteos',
      'Panadería y Repostería': 'zona_panaderia',
      'Quesos y Embutidos': 'zona_embutidos',
      'Despensa': 'pasillo1',
      'Limpieza y Desechables': 'pasillo5',
      'Galletas y Dulces': 'pasillo10',
      'Vinos, licores y cervezas': 'pasillo12',
      'Bebé': 'pasillo13',
      'Listo para Comer': 'pasillo14',
    },
  };

  /// El campo "categoria" en Firebase viene como "Categoría / Subcategoría"
  /// (ej. "Despensa / Arroz").
  static String categoriaRaiz(String categoria) => categoria.split('/').first.trim();

  static String _normalizarCompleta(String categoria) =>
      categoria.split('/').map((p) => p.trim()).join(' / ');

  /// Devuelve el nodoId donde debe llevarse al usuario para ese producto.
  static String? nodoParaCategoria(String sucursalId, String categoria) {
    final exacto = _mapaExactoPorSucursal[sucursalId];
    if (exacto != null) {
      final porSubcategoria = exacto[_normalizarCompleta(categoria)];
      if (porSubcategoria != null) return porSubcategoria;
    }
    final raiz = _mapaRaizPorSucursal[sucursalId];
    if (raiz == null) return null;
    return raiz[categoriaRaiz(categoria)];
  }

  static const Map<String, String> _etiquetasSanIsidro = {
    'pasillo1': 'ACEITES',
    'pasillo2': 'ARROZ',
    'pasillo3': 'AZÚCAR',
    'pasillo4': 'CAFÉ',
    'pasillo5': 'PRODUCTOS DE LIMPIEZA',
    'pasillo6': 'CUIDADO DE LA ROPA',
    'pasillo7': 'DESECHABLES Y FUNDAS',
    'pasillo8': 'PAPEL TOALLA Y MÁS',
    'pasillo9': 'CHOCOLATES',
    'pasillo10': 'GALLETAS',
    'pasillo11': 'GALLETAS SODAS',
    'pasillo12': 'CERVEZAS',
    'pasillo13': 'TOALLAS HÚMEDAS',
    'pasillo14': 'ENLATADOS',
    'pasillo15': 'CONDIMENTOS',
  };

  /// Texto a mostrar verticalmente sobre cada pasillo numérico. Solo San
  /// Isidro tiene etiquetas — Las Américas y Villa Mella se quedan sin
  /// texto (a propósito, son sucursales secundarias).
  static Map<String, String> etiquetasPorPasillo(String sucursalId) {
    if (sucursalId != 'autopista_san_isidro') return {};
    return _etiquetasSanIsidro;
  }

  // Ajuste fino de posición del texto — valores calibrados a mano por
  // Johan viendo el resultado en el dispositivo. NO resetear a cero.
  static const Map<String, Offset> _ajusteEtiquetaSanIsidro = {
    'pasillo1': Offset(0, -0.1),
    'pasillo2': Offset(0, -0.1),
    'pasillo3': Offset(0, -0.1),
    'pasillo4': Offset(-0.01, -0.1),
    'pasillo5': Offset(-0.01, -0.05),
    'pasillo6': Offset(-0.014, -0.05),
    'pasillo7': Offset(-0.023, 0.08),
    'pasillo8': Offset(-0.021, 0.05),
    'pasillo9': Offset(-0.019, -0.03),
    'pasillo10': Offset(-0.01, -0.055),
    'pasillo11': Offset(0, 0),
    'pasillo12': Offset(0, -0.06),
    'pasillo13': Offset(0.01, 0.02),
    'pasillo14': Offset(0.019, -0.04),
    'pasillo15': Offset(0.019, -0.02),
  };

  /// Ajuste fino de posición SOLO del texto — solo aplica a San Isidro,
  /// que es la única sucursal con etiquetas de texto por ahora.
  static Offset ajusteEtiqueta(String sucursalId, String nodoId) {
    if (sucursalId != 'autopista_san_isidro') return Offset.zero;
    return _ajusteEtiquetaSanIsidro[nodoId] ?? Offset.zero;
  }
}