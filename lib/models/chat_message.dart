import '../models/producto.dart';

/// Representa un mensaje dentro del chat de IA — puede ser del usuario
/// o de la IA, y opcionalmente traer una lista de productos propuestos
/// (cada uno se muestra como su propia tarjeta debajo del texto).
class ChatMessage {
  final String texto;
  final bool esDeUsuario;
  final List<Producto>? productos;
  final bool mostrarBotonCarrito;
  final String? imagePath;
  final List<String>? imagenesPromo;

  ChatMessage({
    required this.texto,
    required this.esDeUsuario,
    this.productos,
    this.mostrarBotonCarrito = false,
    this.imagePath,
    this.imagenesPromo,
  });
}