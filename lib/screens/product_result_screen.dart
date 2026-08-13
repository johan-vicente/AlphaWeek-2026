import 'package:flutter/material.dart';
// Ajusta las rutas de importación según la estructura de tus carpetas
import '../services/firebase_service.dart';
import '../models/producto.dart'; // Tu modelo de Producto

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
      body: _buildBody(),
    );
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