import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Popup de 2 pasos: estrellas → comentario opcional.
/// Devuelve:
/// - null si el usuario cierra con la X (vuelve al chat, nada se cierra)
/// - {'cerrar': true} si usa "Cerrar sesión del chat" sin valorar
/// - {'estrellas': int, 'comentario': String?} si completa la valoración
class ValoracionChatPopup extends StatefulWidget {
  const ValoracionChatPopup({super.key});

  @override
  State<ValoracionChatPopup> createState() => _ValoracionChatPopupState();
}

class _ValoracionChatPopupState extends State<ValoracionChatPopup> {
  int _paso = 0; // 0 = estrellas, 1 = comentario
  int _estrellasSeleccionadas = 0;
  bool _confirmado = false;
  final TextEditingController _comentarioController = TextEditingController();

  void _tocarEstrella(int cantidad) {
    setState(() {
      _estrellasSeleccionadas = cantidad;
      _confirmado = false;
    });
  }

  Future<void> _confirmarEstrellas() async {
    setState(() => _confirmado = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() => _paso = 1);
    }
  }

  void _finalizar() {
    Navigator.pop(context, {
      'estrellas': _estrellasSeleccionadas,
      'comentario': _comentarioController.text.trim(),
    });
  }

  void _cerrarSinValorar() {
    Navigator.pop(context, {'cerrar': true});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context, null),
              ),
            ),
            if (_paso == 0) ..._buildPasoEstrellas(),
            if (_paso == 1) ..._buildPasoComentario(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPasoEstrellas() {
    return [
      const Text(
        '¿Cómo calificarías esta conversación?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.negro),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final numero = index + 1;
          final seleccionada = numero <= _estrellasSeleccionadas;
          return IconButton(
            iconSize: 34,
            onPressed: _confirmado ? null : () => _tocarEstrella(numero),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.star_border, size: 34, color: AppColors.azulSirena),
                if (seleccionada)
                  Icon(Icons.star, size: 34, color: AppColors.amarilloSirena),
              ],
            ),
          );
        }),
      ),
      const SizedBox(height: 16),
      if (!_confirmado) ...[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulSirena),
            onPressed: _estrellasSeleccionadas == 0 ? null : _confirmarEstrellas,
            child: const Text('Confirmar', style: TextStyle(color: AppColors.blanco)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _cerrarSinValorar,
            child: const Text(
              'Cerrar sesión del chat',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ] else
        const Text(
          '¡Gracias por tu valoración!',
          style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
        ),
    ];
  }

  List<Widget> _buildPasoComentario() {
    return [
      const Text(
        '¿Quieres dejar un comentario?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.negro),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _comentarioController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Escribe tu opinión (opcional)...',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _finalizar,
              child: const Text('Omitir'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulSirena),
              onPressed: _finalizar,
              child: const Text('Enviar', style: TextStyle(color: AppColors.blanco)),
            ),
          ),
        ],
      ),
    ];
  }
}