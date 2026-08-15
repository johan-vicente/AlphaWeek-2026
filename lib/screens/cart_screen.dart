import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';
import '../widgets/menu_entrada_popup.dart';
import 'sirena_map_screen.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _abrirMenuEntrada(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const MenuEntradaPopup(),
    );
  }

  void _irAHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.azulSirena),
            onPressed: () => _abrirMenuEntrada(context),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.azulSirena),
            onPressed: () => _irAHome(context),
          ),
        ],
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
    final imagenUrl = item.producto.imagenUrl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: (imagenUrl != null && imagenUrl.isNotEmpty)
                  ? Image.network(
                imagenUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.shopping_bag, color: AppColors.azulSirena),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.azulSirena),
                    ),
                  );
                },
              )
                  : const Icon(Icons.shopping_bag, color: AppColors.azulSirena),
            ),
            const SizedBox(width: 12),
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
              final List<String> nodosRuta = cartService.items
                  .map((item) => item.nodoId)
                  .whereType<String>()
                  .toSet()
                  .toList();

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