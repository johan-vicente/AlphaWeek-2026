import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../utils/app_colors.dart';

class VariableWeightDialog extends StatefulWidget {
  final Producto? preselectedProduct;

  const VariableWeightDialog({super.key, this.preselectedProduct});

  @override
  State<VariableWeightDialog> createState() => _VariableWeightDialogState();
}

class _VariableWeightDialogState extends State<VariableWeightDialog> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  List<Producto> _searchResults = [];
  Producto? _selectedProduct;
  bool _isSearching = false;
  double _totalPrice = 0.0;

  /// true cuando el diálogo se abrió SOLO para buscar y elegir un producto
  /// (ej. desde el botón "Por Peso" del escáner) — en ese caso no se pide
  /// la libra aquí, esa parte se resuelve después en la ficha del
  /// producto, igual que con escaneo o entrada manual.
  bool get _modoSoloBuscar => widget.preselectedProduct == null;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedProduct != null) {
      _selectedProduct = widget.preselectedProduct;
    }
  }

  double _getUnitPrice(Producto producto) {
    return producto.precioPorLibra ?? producto.precio ?? 0.0;
  }

  void _onSearchChanged(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _firebaseService.buscarProductosPorNombre(cleanQuery);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    }
  }

  void _calculateTotal() {
    final double? weight = double.tryParse(_weightController.text.trim());
    if (_selectedProduct != null && weight != null && weight > 0) {
      final double unitPrice = _getUnitPrice(_selectedProduct!);
      setState(() {
        _totalPrice = unitPrice * weight;
      });
    } else {
      setState(() {
        _totalPrice = 0.0;
      });
    }
  }

  bool get _puedeConfirmar {
    if (_selectedProduct == null) return false;
    if (_modoSoloBuscar) return true; // no depende del peso aquí
    return _totalPrice > 0;
  }

  void _confirmar() {
    if (_modoSoloBuscar) {
      // Solo se seleccionó el producto — el peso se pide más adelante en
      // la ficha del producto (mismo camino que escaneo/manual).
      Navigator.pop(context, {'producto': _selectedProduct});
      return;
    }
    Navigator.pop(context, {
      'producto': _selectedProduct,
      'libras': double.tryParse(_weightController.text) ?? 0.0,
      'total': _totalPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.blanco,
      title: const Text(
        'Producto por Peso (lb)',
        style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.preselectedProduct == null) ...[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar fruta o vegetal (ej. Manzana)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.cianSirenaMas),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cianSirenaMas, width: 2),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ],
              const SizedBox(height: 12),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isSearching && _searchResults.isNotEmpty && _selectedProduct == null)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      final unitPrice = _getUnitPrice(item);
                      return ListTile(
                        dense: true,
                        title: Text(item.nombre),
                        subtitle: Text('Precio/lb: \$${unitPrice.toStringAsFixed(2)}'),
                        onTap: () {
                          setState(() {
                            _selectedProduct = item;
                            _searchController.text = item.nombre;
                            _searchResults = [];
                          });
                          _calculateTotal();
                        },
                      );
                    },
                  ),
                ),
              if (!_isSearching &&
                  _searchResults.isEmpty &&
                  _searchController.text.trim().isNotEmpty &&
                  _selectedProduct == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No se encontraron productos.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_selectedProduct != null) ...[
                Card(
                  color: AppColors.cianSirenaMas.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cianSirenaMas, width: 1),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    title: Text(
                      _selectedProduct!.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulSirena),
                    ),
                    subtitle: Text('Precio/lb: \$${_getUnitPrice(_selectedProduct!).toStringAsFixed(2)}'),
                    trailing: widget.preselectedProduct == null
                        ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _selectedProduct = null;
                          _searchController.clear();
                          _totalPrice = 0.0;
                        });
                      },
                    )
                        : null,
                  ),
                ),
                // El campo de libra y el total SOLO se muestran cuando ya
                // hay un producto preseleccionado (venimos de "Agregar al
                // Carrito" en la ficha del producto). En modo búsqueda
                // (desde "Por Peso" del escáner) esta parte no aplica —
                // esa zona es solo para encontrar el producto.
                if (!_modoSoloBuscar) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Peso en Libras (lb)',
                      suffixText: 'lb',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.cianSirenaMas, width: 2),
                      ),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.amarilloSirena.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amarilloSirena, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Total:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.negro)),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.azulSirena),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _puedeConfirmar ? _confirmar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.azulSirena,
            foregroundColor: AppColors.blanco,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('AGREGAR', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}