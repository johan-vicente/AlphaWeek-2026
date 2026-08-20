import 'dart:async';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../widgets/header_sirena.dart';
import '../widgets/producto_card.dart';
import '../widgets/main_menu_popup.dart';
import '../widgets/anuncio_popup.dart';
import '../utils/app_colors.dart';
import 'product_result_screen.dart';
import 'bar_scanner_screen.dart';
import 'cart_screen.dart';
import 'chat_ia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  List<Producto> _productos = [];
  bool _cargando = true;
  bool _mostrarSaludo = true;
  Timer? _timerSaludo;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _timerSaludo = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _mostrarSaludo = false);
    });
  }

  @override
  void dispose() {
    _timerSaludo?.cancel();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    final resultado = await _service.buscarProductosPorNombre('');
    setState(() {
      _productos = resultado;
      _cargando = false;
    });
  }

  void _abrirAnuncios() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => const AnuncioPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      drawer: const MainMenuDrawer(),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _mostrarSaludo
                ? Row(
              key: const ValueKey('saludo-visible'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.amarilloSirena,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    '¡Hola! Soy Sira, ¿cómo te ayudo?',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.azulSirena,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
                : const SizedBox(key: ValueKey('saludo-oculto')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatIAScreen()),
              );
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/branding/sira_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            HeaderSirena(
              onAnuncioTap: _abrirAnuncios,
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