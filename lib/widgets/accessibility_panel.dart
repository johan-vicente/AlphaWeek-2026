import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../utils/app_colors.dart';

class AccessibilityPanel extends StatelessWidget {
  const AccessibilityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccessibilityService(),
      builder: (context, _) {
        final service = AccessibilityService();
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.amarilloSirena,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.accessibility_new, color: AppColors.azulSirena),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Accesibilidad',
                        style: TextStyle(
                          color: AppColors.azulSirena,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.negro),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Agrandar texto', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Aumenta el tamaño de la fuente globalmente'),
                        value: service.agrandarTexto,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleAgrandarTexto,
                      ),
                      SwitchListTile(
                        title: const Text('Alto contraste', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Mejora la legibilidad de los colores'),
                        value: service.altoContraste,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleAltoContraste,
                      ),
                      SwitchListTile(
                        title: const Text('Espaciado de texto', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Aumenta el espacio entre letras'),
                        value: service.espaciadoTexto,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleEspaciadoTexto,
                      ),
                      SwitchListTile(
                        title: const Text('Altura de línea', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Aumenta el espacio entre líneas'),
                        value: service.alturaLinea,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleAlturaLinea,
                      ),
                      SwitchListTile(
                        title: const Text('Apto para dislexia', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Cambia la fuente a OpenDyslexic'),
                        value: service.dislexia,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleDislexia,
                      ),
                      SwitchListTile(
                        title: const Text('Escala de grises', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Elimina los colores de la aplicación'),
                        value: service.escalaGrises,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleEscalaGrises,
                      ),
                      SwitchListTile(
                        title: const Text('Reducir animaciones', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Desactiva animaciones de la interfaz'),
                        value: service.reducirAnimaciones,
                        activeColor: AppColors.azulSirena,
                        onChanged: service.toggleReducirAnimaciones,
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restore, color: Colors.red),
                            label: const Text('Restablecer Configuración', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: service.restablecer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
