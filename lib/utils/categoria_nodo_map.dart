import 'package:flutter/material.dart';

/// Mapeo de categoría de producto -> nodo del grafo, por sucursal.
class CategoriaNodoMap {
  // Mapeo para RUTEO (buscador): sigue usando la subcategoría real de
  // Firebase, no cambia aunque el TEXTO que se muestra en el pasillo sea
  // distinto (ver _etiquetaMostrarPorSucursal más abajo).
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
  };

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
  };

  // Texto que se MUESTRA en cada pasillo — independiente del mapeo de
  // ruteo de arriba. pasillo14/15 son decorativos (no hay categoría real
  // de Firebase que buscarlos lleve ahí todavía; cuando agreguen más
  // productos de esas categorías, se pueden conectar en _mapaExactoPorSucursal).
  static const Map<String, Map<String, String>> _etiquetaMostrarPorSucursal = {
    'autopista_san_isidro': {
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
    },
  };

  /// AJUSTE FINO de posición SOLO del texto (no mueve el círculo táctil ni
  /// afecta el cálculo de ruta — eso sigue usando la coordenada real del
  /// pasillo en Firebase). Edita estos valores tú mismo para centrar cada
  /// palabra dentro de su pasillo:
  ///   - dy NEGATIVO sube el texto, dy POSITIVO lo baja
  ///   - dx NEGATIVO lo mueve a la izquierda, dx POSITIVO a la derecha
  /// Son fracciones del ancho/alto de la imagen (mismo sistema 0.0-1.0 que
  /// el grafo) — empieza con pasitos chicos, ej. 0.005 a 0.015.
  /// No requiere volver a correr nada en Firebase: es puramente visual,
  /// con guardar el archivo y hacer hot reload ya se ve el cambio.
  static const Map<String, Map<String, Offset>> _ajusteEtiquetaPorSucursal = {
    'autopista_san_isidro': {
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
    },
  };

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

  /// Texto a mostrar verticalmente sobre cada pasillo numérico.
  static Map<String, String> etiquetasPorPasillo(String sucursalId) {
    return _etiquetaMostrarPorSucursal[sucursalId] ?? {};
  }

  /// Ajuste fino (dx, dy) para la posición del texto de un pasillo dado.
  static Offset ajusteEtiqueta(String sucursalId, String nodoId) {
    return _ajusteEtiquetaPorSucursal[sucursalId]?[nodoId] ?? Offset.zero;
  }
}