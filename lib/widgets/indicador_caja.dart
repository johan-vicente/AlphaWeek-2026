import 'package:flutter/material.dart';
import '../models/caja.dart';
import '../utils/app_colors.dart';

class IndicadorCaja extends StatelessWidget {
  final Caja caja;

  const IndicadorCaja({super.key, required this.caja});

  @override
  Widget build(BuildContext context) {
    final numero = caja.id.replaceAll('caja_', '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: caja.habilitada ? AppColors.cianSirenaMas : Colors.grey.shade400,
            boxShadow: [
              BoxShadow(color: AppColors.sombraSuave, blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          child: Icon(
            caja.habilitada ? Icons.shopping_cart : Icons.close,
            color: AppColors.blanco,
            size: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          numero,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: caja.habilitada ? AppColors.azulSirena : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}