import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/producto.dart';
import '../services/cart_service.dart';
import 'variable_weight_dialog.dart';
import 'cart_screen.dart';
import '../utils/app_colors.dart';

class ProductResultScreen extends StatefulWidget {
  final String barcode;

  const ProductResultScreen({super.key, required this.barcode});

  @override
  State<ProductResultScreen> createState() => _ProductResultScreenState();
}

class _ProductResultScreenState extends State<ProductResultScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  Producto? _producto;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _buscarProducto();
  }

  /// Realiza la búsqueda usando tu FirebaseService existente
  Future<void> _buscarProducto() async {
    try {
      final productoObtenido = await _firebaseService.obtenerProductoPorCodigo(widget.barcode);
      setState(() {
        _producto = productoObtenido;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al consultar la base de datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Producto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: _producto != null && !_isLoading ? _buildBottomBar() : null,
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final cartService = CartService();
    final isInCart = cartService.isProductInCart(widget.barcode);

    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: isInCart
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                    label: const Text('Remover', style: TextStyle(color: Colors.red, fontSize: 16)),
                    onPressed: () {
                      cartService.removeItemByBarcode(widget.barcode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${_producto!.nombre} removido del carrito')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulSirena,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout, color: AppColors.blanco),
                    label: const Text('Ver Carrito', style: TextStyle(color: AppColors.blanco, fontSize: 16)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                ),
              ],
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulSirena,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.add_shopping_cart, color: AppColors.blanco),
              label: const Text('Agregar al Carrito', style: TextStyle(color: AppColors.blanco, fontSize: 18)),
              onPressed: _agregarAlCarrito,
            ),
    );
  }

  void _agregarAlCarrito() async {
    final cartService = CartService();

    if (_producto!.tipoVenta == 'peso_variable') {
      // Mostrar el diálogo de peso si el tipo es peso_variable
      final result = await showDialog(
        context: context,
        builder: (context) => VariableWeightDialog(preselectedProduct: _producto!),
      );

      if (result != null && result is Map) {
        // En un caso real, el diálogo de VariableWeightDialog podría usarse para
        // buscar cualquier producto, pero aquí asumiremos que queremos agregar 
        // el producto devuelto con el peso especificado.
        final prod = result['producto'] as Producto;
        final libras = result['libras'] as double;
        
        cartService.addItem(producto: prod, cantidad: 1, libras: libras);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${prod.nombre} agregado al carrito')),
          );
        }
      }
    } else {
      // Producto empacado normal
      cartService.addItem(producto: _producto!, cantidad: 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_producto!.nombre} agregado al carrito')),
      );
    }
  }

  Widget _buildBody() {
    // 1. Estado de Carga
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Buscando producto con código:\n${widget.barcode}', textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // 2. Estado de Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 3. Caso: Producto No Encontrado
    if (_producto == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 72, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'No se encontró ningún producto registrado con el código:\n${widget.barcode}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver e intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Caso Exitoso: Producto Encontrado
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.deepPurple),
              title: Text(
                _producto!.nombre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Código: ${widget.barcode}'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información General',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Muestra los campos disponibles en tu modelo Producto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Código / PLU:', style: TextStyle(color: Colors.grey)),
                      Text(widget.barcode, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nombre:', style: TextStyle(color: Colors.grey)),
                      Text(_producto!.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}