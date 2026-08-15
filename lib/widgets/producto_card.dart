import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../utils/app_colors.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductoCard({super.key, required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final precioTexto = producto.tipoVenta == 'peso_variable'
        ? 'DOP ${producto.precioPorLibra?.toStringAsFixed(2)} /lb'
        : 'DOP ${producto.precio?.toStringAsFixed(2)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.sombraSuave, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: producto.imagenUrl != null
                  ? Image.network(producto.imagenUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey.shade200),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    precioTexto,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.azulSirena),
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