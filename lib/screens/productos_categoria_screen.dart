import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../widgets/producto_card.dart';
import '../utils/app_colors.dart';
import 'product_result_screen.dart';

class ProductosCategoriaScreen extends StatefulWidget {
  final String categoria;

  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  State<ProductosCategoriaScreen> createState() => _ProductosCategoriaScreenState();
}

class _ProductosCategoriaScreenState extends State<ProductosCategoriaScreen> {
  final FirebaseService _service = FirebaseService();
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final resultado = await _service.buscarProductosPorCategoria(widget.categoria);
    setState(() {
      _productos = resultado;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.amarilloSirena,
        iconTheme: const IconThemeData(color: AppColors.negro),
        title: Text(
          widget.categoria,
          style: const TextStyle(color: AppColors.negro, fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.azulSirena))
          : _productos.isEmpty
          ? const Center(child: Text('No hay productos en esta categoría por ahora.'))
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
                MaterialPageRoute(
                  builder: (_) => ProductResultScreen(barcode: producto.codigoBarra),
                ),
              );
            },
          );
        },
      ),
    );
  }
}