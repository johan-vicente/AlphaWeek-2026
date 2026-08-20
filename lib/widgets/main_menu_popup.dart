import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'menu_entrada_popup.dart';
import 'accessibility_panel.dart';

class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.blanco,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              color: AppColors.amarilloSirena,
              child: Row(
                children: [
                  const Icon(Icons.menu, color: AppColors.azulSirena, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Menú Principal',
                      style: TextStyle(
                        color: AppColors.azulSirena,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront, color: AppColors.azulSirena),
                    title: const Text('Tipo de Entrada', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Delivery, Pickup o SirenaMap'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        builder: (context) => const MenuEntradaPopup(),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.accessibility_new, color: AppColors.azulSirena),
                    title: const Text('Accesibilidad', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Ajustes visuales y de texto'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            top: 40,
                          ),
                          child: const AccessibilityPanel(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
