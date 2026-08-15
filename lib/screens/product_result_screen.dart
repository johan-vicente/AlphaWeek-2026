import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/firebase_service.dart';
import '../models/producto.dart';
import '../services/cart_service.dart';
import 'variable_weight_dialog.dart';
import 'cart_screen.dart';
import '../utils/app_colors.dart';
import '../widgets/header_sirena.dart';

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
          backgroundColor: AppColors.blanco,
          body: SafeArea(
            child: Column(
              children: [
                HeaderSirena(
                  onMenuTap: () => Navigator.pop(context),
                  onBarcodeTap: () => Navigator.pop(context),
                  onCartTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.amarilloSirena.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.production_quantity_limits_rounded,
                  size: 80,
                  color: AppColors.azulSirena,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Ups! No lo encontramos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.negro,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'El producto con el código\n${widget.barcode}\nno está en nuestra base de datos.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulSirena,
                    foregroundColor: AppColors.blanco,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text(
                    'VOLVER A INTENTAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Caso Exitoso: Producto Encontrado
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Imagen del producto
          if (_producto!.imagenUrl != null && _producto!.imagenUrl!.isNotEmpty)
            Image.network(
              _producto!.imagenUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.photo, size: 200, color: Colors.grey),
            )
          else
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Icon(CupertinoIcons.photo, size: 200, color: Colors.grey),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _producto!.nombre.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.azulSirena,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RD\$ ${_producto!.precio?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    color: AppColors.azulSirena,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CÓDIGO DE BARRA: ${widget.barcode}',
                  style: const TextStyle(
                    color: AppColors.azulSirena,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // DISPONIBILIDAD EN SUCURSALES
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.blanco,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.amarilloSirena, width: 4),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.amarilloSirena,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: Text(
                          'DISPONIBILIDAD EN SUCURSALES (${_producto!.sucursales.length})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.azulSirena,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        height: 120, // fixed height for white area as shown
                        padding: const EdgeInsets.all(8.0),
                        child: _producto!.sucursales.isEmpty 
                            ? const Center(child: Text('Sin datos de sucursales'))
                            : ListView.builder(
                                itemCount: _producto!.sucursales.length,
                                itemBuilder: (context, index) {
                                  final sucursal = _producto!.sucursales[index];
                                  final nombre = sucursal is Map ? sucursal['nombre'] : sucursal.toString();
                                  return Text('• $nombre', style: const TextStyle(color: AppColors.azulSirena));
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // PRODUCTOS SIMILARES
          if (_producto!.productosSimilares.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: AppColors.amarilloSirena,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'PRODUCTOS SIMILARES / RELACIONADOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.azulSirena,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _producto!.productosSimilares.length,
                itemBuilder: (context, index) {
                  final sim = _producto!.productosSimilares[index];
                  if (sim is! Map) return const SizedBox.shrink();
                  
                  final nom = sim['nombre'] ?? '';
                  final prec = sim['precio']?.toString() ?? '0.00';
                  final img = sim['imagen_url'];
                  
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (img != null && img.toString().isNotEmpty)
                          Image.network(img, height: 80, fit: BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(CupertinoIcons.photo, size: 80, color: Colors.grey))
                        else
                          const Icon(CupertinoIcons.photo, size: 80, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          nom.toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.azulSirena,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RD\$ $prec',
                          style: const TextStyle(
                            color: AppColors.azulSirena,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}