import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/firebase_service.dart';

class QuejaSugerenciaPopup extends StatefulWidget {
  const QuejaSugerenciaPopup({super.key});

  @override
  State<QuejaSugerenciaPopup> createState() => _QuejaSugerenciaPopupState();
}

class _QuejaSugerenciaPopupState extends State<QuejaSugerenciaPopup> {
  final TextEditingController _textoController = TextEditingController();
  bool _enviado = false;

  Future<void> _enviar() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;

    await FirebaseService().guardarQuejaSugerencia(texto);

    setState(() => _enviado = true);

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: _enviado ? _buildAgradecimiento() : _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.amarilloSirena,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.feedback_outlined, color: AppColors.azulSirena),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Quejas y sugerencias',
                  style: TextStyle(
                    color: AppColors.azulSirena,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: AppColors.negro),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por favor déjanos tu queja o sugerencia:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textoController,
                minLines: 6,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí lo que quieras contarnos...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulSirena,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _enviar,
                  child: const Text('Enviar', style: TextStyle(color: AppColors.blanco)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgradecimiento() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.azulSirena, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Gracias por tu comentario, nos ayuda mucho para seguir mejorando',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulSirena),
          ),
        ],
      ),
    );
  }
}