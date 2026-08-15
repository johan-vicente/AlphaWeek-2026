import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';

class HeaderSirena extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onBarcodeTap;
  final VoidCallback? onCartTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSirenaMasTap;

  const HeaderSirena({
    super.key,
    this.onMenuTap,
    this.onBarcodeTap,
    this.onCartTap,
    this.onSearchChanged,
    this.onSirenaMasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Franja amarilla superior
        Container(
          width: double.infinity,
          color: AppColors.amarilloSirena,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Flexible(
                child: Text(
                  '¡Especiales del Día que no te puedes perder!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.azulSirena,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: AppColors.azulSirena, size: 18),
            ],
          ),
        ),
        // Franja blanca del medio
        Container(
          width: double.infinity,
          color: AppColors.blanco,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.menu, color: AppColors.azulSirena), onPressed: onMenuTap),
              SvgPicture.asset('assets/branding/logo_sirena.svg', height: 26),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.azulSirena, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: onSearchChanged,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: 'Buscar en Sirena',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.amarilloSirena,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search, color: AppColors.azulSirena, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const _IconoCodigoBarra(),
                onPressed: onBarcodeTap,
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: AppColors.azulSirena),
                onPressed: onCartTap,
              ),
            ],
          ),
        ),
        // Franja amarilla inferior — logo + SirenaMás
        InkWell(
          onTap: onSirenaMasTap,
          child: Container(
            width: double.infinity,
            color: AppColors.amarilloSirena,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/branding/logo_sirena.svg', height: 20),
                const SizedBox(width: 6),
                const Text(
                  'SirenaMás',
                  style: TextStyle(
                    color: AppColors.cianSirenaMas,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.cianSirenaMas, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ícono de código de barra dibujado a mano (Material no tiene uno real de barras).
class _IconoCodigoBarra extends StatelessWidget {
  const _IconoCodigoBarra();

  @override
  Widget build(BuildContext context) {
    final anchos = [2.0, 1.0, 3.0, 1.0, 2.0, 1.0, 3.0];
    return SizedBox(
      width: 24,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: anchos
            .map((w) => Container(width: w, color: AppColors.azulSirena))
            .toList(),
      ),
    );
  }
}