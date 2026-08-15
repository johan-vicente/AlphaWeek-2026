import 'package:flutter/material.dart';

class SirenaMapScreen extends StatelessWidget {
  final List<String> nodosDestino;

  const SirenaMapScreen({super.key, required this.nodosDestino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa y Rutas (SirenaMap)'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 100, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Pantalla de Mapa (Issue 17)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Nodos recibidos para cálculo de ruta (Issue 10):'),
              const SizedBox(height: 8),
              if (nodosDestino.isEmpty)
                const Text('No hay nodos seleccionados.', style: TextStyle(color: Colors.grey))
              else
                Wrap(
                  spacing: 8,
                  children: nodosDestino
                      .map((nodo) => Chip(label: Text(nodo)))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
