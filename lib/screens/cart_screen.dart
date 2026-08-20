import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';
import '../widgets/main_menu_popup.dart';
import 'sirena_map_screen.dart';
import 'home_screen.dart';
import 'chat_ia_screen.dart';
import '../widgets/seleccionar_sucursal_popup.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _copiado = false;
  Timer? _timerCopiado;

  @override
  void dispose() {
    _timerCopiado?.cancel();
    super.dispose();
  }

  void _irAHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  String _emojiParaCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('limpieza') || cat.contains('desechables')) return '🧼';
    if (cat.contains('frutas') || cat.contains('vegetales') || cat.contains('víveres') || cat.contains('viveres')) return '🥦';
    if (cat.contains('lácteos') || cat.contains('lacteos') || cat.contains('huevos')) return '🥛';
    if (cat.contains('panadería') || cat.contains('panaderia')) return '🍞';
    if (cat.contains('galletas') || cat.contains('dulces') || cat.contains('chocolates')) return '🍪';
    if (cat.contains('pollo')) return '🍗';
    if (cat.contains('cerdo')) return '🥩';
    if (cat.contains('carnes') || cat.contains('res')) return '🥩';
    if (cat.contains('bebidas')) return '🥤';
    if (cat.contains('quesos') || cat.contains('embutidos')) return '🧀';
    if (cat.contains('bebé') || cat.contains('bebe')) return '👶';
    if (cat.contains('vinos') || cat.contains('cervezas')) return '🍺';
    if (cat.contains('especias') || cat.contains('condimentos')) return '🧂';
    if (cat.contains('despensa')) return '🥫';
    return '🛍️';
  }

  void _copiarCarrito(BuildContext context, CartService cartService) {
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío, no hay nada que copiar')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🛒 *Mi lista de compras - Sirena*');
    buffer.writeln('');

    for (final item in cartService.items) {
      final emoji = _emojiParaCategoria(item.producto.categoria);
      final detalle = item.producto.tipoVenta == 'peso_variable'
          ? '${item.libras.toStringAsFixed(2)} lb'
          : '${item.cantidad} und';
      buffer.writeln(
        '$emoji ${item.producto.nombre} — $detalle — \$${item.subtotal.toStringAsFixed(2)}',
      );
    }

    buffer.writeln('');
    buffer.writeln('*Total: \$${cartService.total.toStringAsFixed(2)}*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    _timerCopiado?.cancel();
    setState(() => _copiado = true);
    _timerCopiado = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copiado = false);
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.azulSirena),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulSirena,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: Icon(
                  _copiado ? Icons.check : Icons.copy,
                  color: AppColors.blanco,
                  size: 16,
                ),
                label: Text(
                  _copiado ? '¡Copiado!' : 'Copiar carrito',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.blanco),
                ),
                onPressed: () => _copiarCarrito(context, cartService),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          if (cartService.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.amarilloSirena),
                    icon: const Icon(Icons.add_shopping_cart, color: AppColors.azulSirena),
                    label: const Text('Agregar productos', style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold)),
                    onPressed: () => _irAHome(context),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulSirena),
                    icon: const Icon(Icons.chat, color: AppColors.blanco),
                    label: const Text('Hablar con Asistente Sira', style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatIAScreen()));
                    },
                  ),
                ],
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
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.azulSirena,
                      onPressed: () => esVariable
                          ? cartService.actualizarLibras(item, -1)
                          : cartService.updateQuantity(item, -1),
                    ),
                    Text(
                      esVariable ? item.libras.toStringAsFixed(0) : '${item.cantidad}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.azulSirena,
                      onPressed: () => esVariable
                          ? cartService.actualizarLibras(item, 1)
                          : cartService.updateQuantity(item, 1),
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
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black54,
                builder: (context) => const SeleccionarSucursalPopup(),
              );
            },
          ),
        ],
      ),
    );
  }
}