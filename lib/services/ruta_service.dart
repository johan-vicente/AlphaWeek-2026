import 'dart:collection';
import '../models/nodo_grafo.dart';

class RutaService {
  /// Calcula la ruta más corta entre [origen] y [destino] dentro de [nodos].
  /// Devuelve la lista de ids de nodos en orden, o [] si no hay ruta posible.
  List<String> calcularRuta(Map<String, NodoGrafo> nodos, String origen, String destino) {
    if (!nodos.containsKey(origen) || !nodos.containsKey(destino)) return [];
    if (origen == destino) return [origen];

    final visitados = <String>{origen};
    final cola = Queue<String>()..add(origen);
    final padres = <String, String>{};

    while (cola.isNotEmpty) {
      final actual = cola.removeFirst();

      if (actual == destino) {
        return _reconstruirCamino(padres, origen, destino);
      }

      final nodoActual = nodos[actual];
      if (nodoActual == null) continue;

      for (final vecinoId in nodoActual.conexiones) {
        if (!visitados.contains(vecinoId) && nodos.containsKey(vecinoId)) {
          visitados.add(vecinoId);
          padres[vecinoId] = actual;
          cola.add(vecinoId);
        }
      }
    }

    return []; // no hay ruta posible
  }

  List<String> _reconstruirCamino(Map<String, String> padres, String origen, String destino) {
    final camino = <String>[destino];
    String actual = destino;
    while (actual != origen) {
      actual = padres[actual]!;
      camino.add(actual);
    }
    return camino.reversed.toList();
  }
}