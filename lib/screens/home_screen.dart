import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../widgets/header_sirena.dart';
import '../widgets/producto_card.dart';
import '../widgets/menu_entrada_popup.dart';
import '../utils/app_colors.dart';
import 'product_result_screen.dart';
import 'bar_scanner_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final resultado = await _service.buscarProductosPorNombre('');
    setState(() {
      _productos = resultado;
      _cargando = false;
    });
  }

  void _abrirMenuEntrada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const MenuEntradaPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: Column(
          children: [
            HeaderSirena(
              onMenuTap: _abrirMenuEntrada,
              onBarcodeTap: () async {
                final codigoEscaneado = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                );

                if (codigoEscaneado != null && codigoEscaneado.isNotEmpty && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductResultScreen(barcode: codigoEscaneado)),
                  );
                }
              },
              onCartTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              onSearchChanged: (query) async {
                final resultado = await _service.buscarProductosPorNombre(query);
                setState(() => _productos = resultado);
              },
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.azulSirena))
                  : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return ProductoCard(
                    producto: producto,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductResultScreen(barcode: producto.codigoBarra)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}