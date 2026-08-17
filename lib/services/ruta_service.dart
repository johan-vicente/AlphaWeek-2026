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

  /// Distancia en línea recta entre dos nodos, usando sus coordenadas x/y.
  /// Se usa para decidir cuál destino está geográficamente más cerca —
  /// NO se usa la distancia del camino del grafo (BFS), porque ese camino
  /// pasa por nodos de corredor cuya posición es una abstracción lógica,
  /// no un lugar real, y distorsiona la comparación (ej. hacía que un
  /// destino en línea recta más lejos pareciera "más cercano" solo porque
  /// su camino en el grafo tenía menos distancia acumulada).
  double _distanciaDirecta(Map<String, NodoGrafo> nodos, String a, String b) {
    final na = nodos[a];
    final nb = nodos[b];
    if (na == null || nb == null) return double.infinity;
    final dx = na.x - nb.x;
    final dy = na.y - nb.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calcula una ruta que visita todos los [destinos] partiendo de [origen],
  /// usando la heurística del vecino más cercano (suficiente para 2-4 destinos).
  /// "Más cercano" se decide por distancia real en línea recta entre
  /// coordenadas, no por la ruta del grafo — así el orden de visita refleja
  /// la cercanía geográfica real, no un artefacto de cómo está armado el
  /// grafo de corredores.
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

        final distancia = _distanciaDirecta(nodos, actual, destino);
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