import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color color;

  const BotonPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.color = AppColors.azulSirena,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 3,
          shadowColor: AppColors.sombraSuave,
        ),
        child: Text(
          texto.toUpperCase(),
          style: const TextStyle(
            color: AppColors.blanco,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}