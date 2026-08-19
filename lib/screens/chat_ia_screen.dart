import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/producto.dart';
import '../services/claude_service.dart';
import '../services/tools_ia.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/valoracion_chat_popup.dart';
import 'product_result_screen.dart';
import 'cart_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  static final List<ChatMessage> _mensajes = [];
  static int _mensajesEnviadosSesion = 0;
  static const int _maxMensajesPorSesion = 25;
  static DateTime? _ultimoEnvio;
  static const Duration _cooldownMensaje = Duration(seconds: 2);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _cargando = false;
  bool _modoOscuro = false;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _textoPrevio = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _iniciarEscucha() async {
    if (_speechEnabled) {
      _textoPrevio = _inputController.text;
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _inputController.text = _textoPrevio.isEmpty
                ? result.recognizedWords
                : '$_textoPrevio ${result.recognizedWords}';
            _inputController.selection = TextSelection.fromPosition(
                TextPosition(offset: _inputController.text.length));
          });
        },
      );
      setState(() {
        _isListening = true;
      });
    } else {
      _initSpeech();
    }
  }

  void _detenerEscucha() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _enviarMensaje([String? textoForzado]) async {
    if (_isListening) _detenerEscucha();
    final texto = (textoForzado ?? _inputController.text).trim();
    if (texto.isEmpty || _cargando) return;

    if (_mensajesEnviadosSesion >= _maxMensajesPorSesion) {
      setState(() {
        _mensajes.add(ChatMessage(
          texto: 'Llegaste al límite de mensajes de esta sesión. Finaliza el '
              'chat y ábrelo de nuevo para continuar.',
          esDeUsuario: false,
        ));
      });
      _scrollAlFinal();
      return;
    }

    final ahora = DateTime.now();
    if (_ultimoEnvio != null && ahora.difference(_ultimoEnvio!) < _cooldownMensaje) {
      return;
    }
    _ultimoEnvio = ahora;
    _mensajesEnviadosSesion++;

    setState(() {
      _mensajes.add(ChatMessage(texto: texto, esDeUsuario: true));
      _cargando = true;
    });
    _inputController.clear();
    _scrollAlFinal();

    ToolsIA.ultimosProductosMostrados = [];
    ToolsIA.seAgregoAlCarrito = false;

    try {
      final resp = await ClaudeService().enviarMensajeConTools(texto);
      final textoRespuesta = ClaudeService().extraerTexto(resp);
      final productos = List<Producto>.from(ToolsIA.ultimosProductosMostrados);

      setState(() {
        _mensajes.add(ChatMessage(
          texto: textoRespuesta,
          esDeUsuario: false,
          productos: productos.isNotEmpty ? productos : null,
          mostrarBotonCarrito: ToolsIA.seAgregoAlCarrito,
        ));
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.add(ChatMessage(
          texto: 'Hubo un problema conectando con el asistente. Intenta de nuevo.',
          esDeUsuario: false,
        ));
        _cargando = false;
      });
    }
    _scrollAlFinal();
  }

  Future<void> _cerrarChat() async {
    final resultado = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ValoracionChatPopup(),
    );

    // Si tocó la X, se queda en el chat tal cual — no se cierra sesión.
    if (resultado == null) return;

    final resumen = await ClaudeService().generarResumen();

    if (resumen.isNotEmpty) {
      await LocalStorageService.guardarDatoChatIA('ultimo_resumen', resumen);
    }

    // Solo guarda en Firebase si SÍ valoró (no si usó "Cerrar sesión del chat").
    if (resultado.containsKey('estrellas')) {
      var idUsuario = LocalStorageService.obtenerDatoChatIA('usuario_id');
      if (idUsuario == null) {
        idUsuario = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';
        await LocalStorageService.guardarDatoChatIA('usuario_id', idUsuario);
      }

      await FirebaseService().guardarValoracionChat({
        'estrellas': resultado['estrellas'],
        'comentario': resultado['comentario'],
        'resumen': resumen,
        'usuario_id': idUsuario,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    ClaudeService().reiniciarConversacion();
    _mensajes.clear();
    _mensajesEnviadosSesion = 0;

    if (mounted) Navigator.pop(context);
  }

  void _scrollAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF1A1A1A) : AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.amarilloSirena,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.negro),
        title: const Text(
          'Sira, tu IA zerca de ti',
          style: TextStyle(color: AppColors.negro, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Finalizar sesión',
            onPressed: _cerrarChat,
          ),
          IconButton(
            icon: Icon(_modoOscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _modoOscuro = !_modoOscuro),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length + (_cargando ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mensajes.length) {
                  return _buildBurbujaCargando();
                }
                return _buildMensaje(_mensajes[index]);
              },
            ),
          ),
          if (_mensajes.isEmpty) _buildChipsSugerencia(),
          _buildBarraInput(),
        ],
      ),
    );
  }

  Widget _buildChipsSugerencia() {
    final sugerencias = [
      'Quiero armar mi carrito',
      '¿Tienen tal producto?',
      'Arma mi lista con presupuesto',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sugerencias.map((texto) {
          return ActionChip(
            label: Text(texto, style: const TextStyle(fontSize: 13)),
            backgroundColor: AppColors.amarilloSirena.withOpacity(0.25),
            side: BorderSide(color: AppColors.amarilloSirena),
            onPressed: () => _enviarMensaje(texto),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMensaje(ChatMessage mensaje) {
    final esUsuario = mensaje.esDeUsuario;
    return Column(
      crossAxisAlignment:
      esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: esUsuario
                  ? AppColors.azulSirena
                  : (_modoOscuro ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mensaje.texto,
              style: TextStyle(
                color: esUsuario
                    ? AppColors.blanco
                    : (_modoOscuro ? AppColors.blanco : AppColors.negro),
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (mensaje.productos != null && mensaje.productos!.isNotEmpty)
          ...mensaje.productos!.map((p) => _buildTarjetaProducto(p)),
        if (mensaje.mostrarBotonCarrito)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulSirena),
              icon: const Icon(Icons.shopping_cart, color: AppColors.blanco, size: 18),
              label: const Text('Ver carrito', style: TextStyle(color: AppColors.blanco)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTarjetaProducto(Producto producto) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductResultScreen(barcode: producto.codigoBarra),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _modoOscuro ? const Color(0xFF2A2A2A) : AppColors.blanco,
          border: Border.all(
            color: _modoOscuro ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: (producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty)
                  ? Image.network(
                producto.imagenUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shopping_bag,
                  color: AppColors.azulSirena,
                ),
              )
                  : const Icon(Icons.shopping_bag, color: AppColors.azulSirena),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _modoOscuro ? AppColors.blanco : AppColors.negro,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${producto.calcularPrecio().toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.azulSirena, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _modoOscuro ? Colors.grey.shade400 : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBurbujaCargando() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _modoOscuro ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.azulSirena),
        ),
      ),
    );
  }

  Widget _buildBarraInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF1A1A1A) : AppColors.blanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                style: TextStyle(color: _modoOscuro ? AppColors.blanco : AppColors.negro),
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(
                    color: _modoOscuro ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: _modoOscuro ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _enviarMensaje(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _isListening ? Colors.redAccent : AppColors.amarilloSirena,
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: AppColors.negro, size: 20),
                onPressed: () {
                  if (_isListening) {
                    _detenerEscucha();
                  } else {
                    _iniciarEscucha();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.azulSirena,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.blanco, size: 20),
                onPressed: () => _enviarMensaje(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}