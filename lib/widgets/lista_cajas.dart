import 'package:flutter/material.dart';
import '../models/caja.dart';
import '../services/firebase_service.dart';
import 'indicador_caja.dart';

class ListaCajas extends StatelessWidget {
  final String sucursalId;
  final FirebaseService _service = FirebaseService();

  ListaCajas({super.key, required this.sucursalId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<dynamic, dynamic>>(
      stream: _service.escucharCajas(sucursalId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final cajas = snapshot.data!.entries
            .map((e) => Caja.fromMap(e.key, e.value as Map<dynamic, dynamic>))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));

        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: cajas.map((c) => IndicadorCaja(caja: c)).toList(),
        );
      },
    );
  }
}