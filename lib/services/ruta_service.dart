import 'dart:collection';
import 'dart:math' as math;
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

  /// Distancia real (euclidiana, sumando cada tramo del camino) usando las
  /// coordenadas x/y de los nodos. Se usa para desempatar cuando dos
  /// destinos quedan a la misma cantidad de pasos (hops) del grafo — algo
  /// muy común en este grafo porque casi todo pasa por el mismo corredor
  /// central, así que "cantidad de pasos" sola no distingue bien cuál está
  /// geográficamente más cerca.
  double _distanciaReal(Map<String, NodoGrafo> nodos, List<String> camino) {
    double total = 0;
    for (int i = 1; i < camino.length; i++) {
      final a = nodos[camino[i - 1]];
      final b = nodos[camino[i]];
      if (a == null || b == null) continue;
      final dx = a.x - b.x;
      final dy = a.y - b.y;
      total += math.sqrt(dx * dx + dy * dy);
    }
    return total;
  }

  /// Calcula una ruta que visita todos los [destinos] partiendo de [origen],
  /// usando la heurística del vecino más cercano (suficiente para 2-4 destinos).
  /// El "más cercano" se decide por distancia REAL en el mapa, no solo por
  /// cantidad de pasos del grafo — así el orden de visita no depende de en
  /// qué orden vinieron los destinos (ej. orden del carrito), sino de cuál
  /// está geográficamente más cerca de verdad.
  List<String> calcularRutaMultiDestino(
      Map<String, NodoGrafo> nodos,
      String origen,
      List<String> destinos,
      ) {
    final pendientes = destinos.toSet()..remove(origen);
    if (pendientes.isEmpty) return [origen];

    final rutaCompleta = <String>[origen];
    String actual = origen;

    while (pendientes.isNotEmpty) {
      String? masCercano;
      List<String> mejorTramo = [];
      double mejorDistancia = double.infinity;

      for (final destino in pendientes) {
        final tramo = calcularRuta(nodos, actual, destino);
        if (tramo.isEmpty) continue; // no hay ruta posible a este destino

        final distancia = _distanciaReal(nodos, tramo);
        if (masCercano == null || distancia < mejorDistancia) {
          masCercano = destino;
          mejorTramo = tramo;
          mejorDistancia = distancia;
        }
      }

      if (masCercano == null) break; // ningún destino restante es alcanzable
      rutaCompleta.addAll(mejorTramo.sublist(1)); // sin repetir el nodo actual
      actual = masCercano;
      pendientes.remove(masCercano);
    }

    return rutaCompleta;
  }
}