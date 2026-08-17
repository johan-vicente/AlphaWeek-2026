import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductoCard({super.key, required this.producto, required this.onTap});

  /// Busca el CartItem de este producto en el carrito (por código de barra).
  /// Para peso_variable puede haber varias entradas distintas del mismo
  /// producto (cada pesada es su propio ítem) — aquí solo se usa para
  /// productos empacados, que sí se agrupan en un único ítem.
  CartItem? _buscarItemEnCarrito() {
    for (final item in CartService().items) {
      if (item.producto.codigoBarra == producto.codigoBarra) return item;
    }
    return null;
  }

  void _agregarAlCarrito() {
    if (producto.tipoVenta == 'peso_variable') {
      // Simplificado para el Home: agrega 1 libra directo, sin abrir el
      // diálogo de peso que se usa en el flujo del escáner.
      CartService().addItem(producto: producto, libras: 1.0);
    } else {
      CartService().addItem(producto: producto);
    }
  }

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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  producto.imagenUrl != null
                      ? Image.network(producto.imagenUrl!, fit: BoxFit.cover, width: double.infinity)
                      : Container(color: Colors.grey.shade200),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _BotonCantidad(
                      producto: producto,
                      buscarItem: _buscarItemEnCarrito,
                      onAgregar: _agregarAlCarrito,
                    ),
                  ),
                ],
              ),
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

/// El botón flotante en la esquina de la tarjeta: un "+" solo mientras el
/// producto no está en el carrito, y la fila "- cantidad +" en cuanto se
/// agrega (productos empacados). Para peso_variable siempre se queda como
/// un "+" simple, porque cada toque agrega una pesada nueva por separado.
/// Escucha CartService directo (AnimatedBuilder) para reflejar cambios sin
/// que HomeScreen tenga que manejar ese estado.
class _BotonCantidad extends StatelessWidget {
  final Producto producto;
  final CartItem? Function() buscarItem;
  final VoidCallback onAgregar;

  const _BotonCantidad({
    required this.producto,
    required this.buscarItem,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService(),
      builder: (context, _) {
        final esPesoVariable = producto.tipoVenta == 'peso_variable';
        final item = esPesoVariable ? null : buscarItem();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.sombraSuave, blurRadius: 3, offset: const Offset(0, 1))],
          ),
          child: (item == null)
              ? GestureDetector(
            onTap: onAgregar,
            child: const Icon(Icons.add_circle, color: AppColors.azulSirena, size: 26),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => CartService().updateQuantity(item, -1),
                child: const Icon(Icons.remove_circle_outline, color: AppColors.azulSirena, size: 18),
              ),
              const SizedBox(width: 4),
              Text(
                '${item.cantidad}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => CartService().updateQuantity(item, 1),
                child: const Icon(Icons.add_circle_outline, color: AppColors.azulSirena, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}