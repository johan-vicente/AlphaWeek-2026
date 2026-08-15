import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';
import 'sirena_map_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Carrito',
          style: TextStyle(color: AppColors.negro, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.amarilloSirena,
        iconTheme: const IconThemeData(color: AppColors.negro),
      ),
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          if (cartService.items.isEmpty) {
            return const Center(
              child: Text(
                'Tu carrito está vacío',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    return _buildCartItem(context, item, cartService);
                  },
                ),
              ),
              _buildBottomBar(context, cartService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartService cartService) {
    final esVariable = item.producto.tipoVenta == 'peso_variable';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono o Imagen genérica
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.azulSirena),
            ),
            const SizedBox(width: 12),
            // Detalles del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (esVariable)
                    Text('${item.libras.toStringAsFixed(2)} lb x \$${item.producto.precioPorLibra?.toStringAsFixed(2)}/lb', style: const TextStyle(color: Colors.grey, fontSize: 13))
                  else
                    Text('Precio Unit: \$${item.producto.precio?.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulSirena),
                  ),
                ],
              ),
            ),
            // Controles de cantidad y botón eliminar
            Column(
              children: [
                Row(
                  children: [
                    if (!esVariable)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.azulSirena,
                        onPressed: () => cartService.updateQuantity(item, -1),
                      ),
                    if (!esVariable)
                      Text('${item.cantidad}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (!esVariable)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.azulSirena,
                        onPressed: () => cartService.updateQuantity(item, 1),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => cartService.removeItem(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartService cartService) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraSuave,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${cartService.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.azulSirena),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulSirena,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulación: Compra Finalizada con Éxito')),
              );
              cartService.clearCart();
            },
            child: const Text(
              'Finalizar Compra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blanco),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.azulSirena, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.map_outlined, color: AppColors.azulSirena),
            label: const Text(
              'Ir a SirenaMap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.azulSirena),
            ),
            onPressed: () {
              // Recopilar nodos asociados a los productos
              final List<String> nodosRuta = cartService.items
                  .map((item) => item.nodoId)
                  .whereType<String>()
                  .toSet()
                  .toList(); // toSet para evitar duplicados

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SirenaMapScreen(nodosDestino: nodosRuta),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
