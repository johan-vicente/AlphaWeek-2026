import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Producto por Peso (Libras)'),
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
                  decoration: const InputDecoration(
                    labelText: 'Buscar fruta o vegetal (ej. Manzana)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
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
                  color: Colors.deepPurple.shade50,
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    title: Text(_selectedProduct!.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Precio/lb: \$${_getUnitPrice(_selectedProduct!).toStringAsFixed(2)}'),
                    trailing: widget.preselectedProduct == null
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
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
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso en Libras (lb)',
                    suffixText: 'lb',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _calculateTotal(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Precio Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_selectedProduct != null && _totalPrice > 0)
              ? () {
            Navigator.pop(context, {
              'producto': _selectedProduct,
              'libras': double.tryParse(_weightController.text) ?? 0.0,
              'total': _totalPrice,
            });
          }
              : null,
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}