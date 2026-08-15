import 'package:flutter/material.dart';
import '../models/producto.dart';

class CartItem {
  final Producto producto;
  int cantidad;
  double libras;
  String? nodoId;

  CartItem({
    required this.producto,
    this.cantidad = 1,
    this.libras = 0.0,
    this.nodoId,
  });

  double get subtotal {
    if (producto.tipoVenta == 'peso_variable') {
      return (producto.precioPorLibra ?? producto.precio ?? 0) * libras;
    }
    return (producto.precio ?? 0) * cantidad;
  }
}

class CartService extends ChangeNotifier {
  // Patrón Singleton
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem({
    required Producto producto,
    int cantidad = 1,
    double libras = 0.0,
  }) {
    // Si es empacado, agrupar cantidades si ya existe el producto
    if (producto.tipoVenta != 'peso_variable') {
      final index = _items.indexWhere((item) => item.producto.codigoBarra == producto.codigoBarra);
      if (index != -1) {
        _items[index].cantidad += cantidad;
        notifyListeners();
        return;
      }
    }
    
    // Si no existe, o es peso variable, se añade un nuevo ítem
    _items.add(
      CartItem(
        producto: producto,
        cantidad: cantidad,
        libras: libras,
        nodoId: _getNodoForCategoria(producto.categoria),
      ),
    );
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void removeItemByBarcode(String barcode) {
    _items.removeWhere((item) => item.producto.codigoBarra == barcode);
    notifyListeners();
  }

  bool isProductInCart(String barcode) {
    return _items.any((item) => item.producto.codigoBarra == barcode);
  }

  void updateQuantity(CartItem item, int delta) {
    if (item.producto.tipoVenta == 'peso_variable') {
      // Para productos de peso variable, no actualizamos "cantidad" con botones +/-
      return;
    }

    final newQuantity = item.cantidad + delta;
    if (newQuantity <= 0) {
      removeItem(item);
    } else {
      item.cantidad = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Mapeo simple de categoría a un nodoId del grafo
  String? _getNodoForCategoria(String categoria) {
    final catLower = categoria.toLowerCase();
    if (catLower.contains('despensa')) return 'n7';
    if (catLower.contains('limpieza') || catLower.contains('desechables')) return 'n11';
    if (catLower.contains('panadería') || catLower.contains('pan')) return 'n13';
    if (catLower.contains('lácteos') || catLower.contains('huevos')) return 'n8';
    if (catLower.contains('bebidas')) return 'n14';
    if (catLower.contains('galletas') || catLower.contains('dulces')) return 'n9';
    if (catLower.contains('frutas') || catLower.contains('vegetales')) return 'n10';
    if (catLower.contains('quesos') || catLower.contains('embutidos')) return 'n12';
    // Fallback: Si no coincide con ninguna zona, se puede mapear a un nodo predeterminado.
    return 'n1';
  }
}
