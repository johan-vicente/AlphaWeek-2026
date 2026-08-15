import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/menu_entrada_popup.dart';
import 'home_screen.dart';

class SirenaMapScreen extends StatelessWidget {
  final List<String> nodosDestino;

  const SirenaMapScreen({super.key, required this.nodosDestino});

  void _abrirMenuEntrada(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const MenuEntradaPopup(),
    );
  }

  void _irAHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa y Rutas (SirenaMap)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.azulSirena),
            onPressed: () => _abrirMenuEntrada(context),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.azulSirena),
            onPressed: () => _irAHome(context),
          ),
        ],
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