import 'package:flutter/material.dart';
import '../models/nodo_grafo.dart';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../services/ruta_service.dart';
import '../services/cart_service.dart';
import '../utils/app_colors.dart';
import '../utils/categoria_nodo_map.dart';
import '../widgets/header_sirena.dart';
import '../widgets/menu_entrada_popup.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'bar_scanner_screen.dart';
import 'product_result_screen.dart';

const Map<String, String> _nombreCortoSucursal = {
  'autopista_san_isidro': 'San Isidro',
  'villa_mella': 'Villa Mella',
  'las_americas': 'Las Américas',
};

const double _aspectRatioMapa = 1454 / 1710;

class SirenaMapScreen extends StatefulWidget {
  final String sucursalId;
  final bool preguntarPorCarritoAlEntrar;

  const SirenaMapScreen({
    super.key,
    required this.sucursalId,
    this.preguntarPorCarritoAlEntrar = false,
  });

  @override
  State<SirenaMapScreen> createState() => _SirenaMapScreenState();
}

class _SirenaMapScreenState extends State<SirenaMapScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final RutaService _rutaService = RutaService();
  final TextEditingController _busquedaController = TextEditingController();

  Map<String, NodoGrafo> _nodos = {};
  bool _cargandoGrafo = true;

  String? _origenId;
  List<String> _rutaActual = [];
  List<String> _destinosEnOrden = [];

  bool _esperandoOrigenManual = false;
  bool _mostrarBuscador = false;
  List<Producto> _resultadosBusqueda = [];
  bool _buscando = false;

  Map<dynamic, dynamic> _cajas = {};

  bool get _hayRutaCalculada => _rutaActual.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _cargarGrafo();
    _escucharCajas();

    if (widget.preguntarPorCarritoAlEntrar) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _preguntarPorCarrito());
    } else {
      _esperandoOrigenManual = true;
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarGrafo() async {
    final nodos = await _firebaseService.obtenerGrafoComoNodos(widget.sucursalId);
    if (mounted) {
      setState(() {
        _nodos = nodos;
        _cargandoGrafo = false;
      });
    }
  }

  void _escucharCajas() {
    _firebaseService.escucharCajas(widget.sucursalId).listen((data) {
      if (mounted) setState(() => _cajas = data);
    });
  }

  Future<void> _preguntarPorCarrito() async {
    final quiere = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¿Te guiamos a tus productos?'),
        content: const Text(
          'Tienes productos en tu carrito. ¿Quieres que calculemos la ruta hasta ellos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, gracias'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, guíame',
              style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (quiere == true) {
      _calcularRutaConCarrito();
    } else {
      _iniciarModoManual();
    }
  }

  void _iniciarModoManual() {
    setState(() {
      _origenId = null;
      _rutaActual = [];
      _destinosEnOrden = [];
      _esperandoOrigenManual = true;
      _mostrarBuscador = false;
    });
  }

  void _reiniciarSeleccion() {
    setState(() {
      _origenId = null;
      _rutaActual = [];
      _destinosEnOrden = [];
      _esperandoOrigenManual = true;
      _mostrarBuscador = false;
      _busquedaController.clear();
      _resultadosBusqueda = [];
    });
  }

  void _calcularRutaConCarrito() {
    final items = CartService().items;
    if (items.isEmpty) {
      _mostrarMensaje('Llena tu carrito para guiarte');
      return;
    }
    if (_nodos.isEmpty) {
      _mostrarMensaje('El mapa todavía está cargando, intenta de nuevo en un momento');
      return;
    }

    final destinos = <String>{};
    for (final item in items) {
      final nodoId = CategoriaNodoMap.nodoParaCategoria(widget.sucursalId, item.producto.categoria);
      if (nodoId != null) destinos.add(nodoId);
    }

    if (destinos.isEmpty) {
      _mostrarMensaje('No pudimos ubicar tus productos en el mapa de esta sucursal');
      return;
    }

    final ruta = _rutaService.calcularRutaMultiDestino(_nodos, 'entrada', destinos.toList());

    if (ruta.isEmpty) {
      _mostrarMensaje('No encontramos una ruta posible hacia tus productos');
      return;
    }

    setState(() {
      _origenId = 'entrada';
      _rutaActual = ruta;
      _destinosEnOrden = _ordenarDestinosSegunRuta(ruta, destinos);
      _esperandoOrigenManual = false;
      _mostrarBuscador = false;
    });
  }

  List<String> _ordenarDestinosSegunRuta(List<String> ruta, Set<String> destinos) {
    final orden = <String>[];
    for (final id in ruta) {
      if (destinos.contains(id) && !orden.contains(id)) {
        orden.add(id);
      }
    }
    return orden;
  }

  /// Toque sobre un nodo del mapa: si se está esperando el origen, lo fija.
  /// Si ya hay origen (buscando destino, o incluso con una ruta ya
  /// calculada), tocar directamente un pasillo/zona calcula la ruta hacia
  /// ahí al toque — alternativa al buscador para quien ya conoce el mapa.
  void _onTapNodo(String nodoId) {
    if (_esperandoOrigenManual) {
      setState(() {
        _origenId = nodoId;
        _esperandoOrigenManual = false;
        _mostrarBuscador = true;
        _rutaActual = [];
        _destinosEnOrden = [];
      });
      return;
    }

    if (_origenId != null) {
      _calcularRutaHaciaNodo(nodoId);
    }
  }

  void _calcularRutaHaciaNodo(String nodoId) {
    if (_origenId == null) return;
    final ruta = _rutaService.calcularRuta(_nodos, _origenId!, nodoId);
    if (ruta.isEmpty) {
      _mostrarMensaje('No encontramos una ruta posible hacia ese punto');
      return;
    }
    setState(() {
      _rutaActual = ruta;
      _destinosEnOrden = [nodoId];
      _mostrarBuscador = false;
      _busquedaController.clear();
      _resultadosBusqueda = [];
    });
  }

  Future<void> _buscarProducto(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _resultadosBusqueda = []);
      return;
    }
    setState(() => _buscando = true);
    final resultados = await _firebaseService.buscarProductosPorNombre(query);
    final disponibles = resultados.where((p) => p.sucursales.contains(widget.sucursalId)).toList();
    if (mounted) {
      setState(() {
        _resultadosBusqueda = disponibles;
        _buscando = false;
      });
    }
  }

  void _seleccionarProductoDestino(Producto producto) {
    final nodoId = CategoriaNodoMap.nodoParaCategoria(widget.sucursalId, producto.categoria);
    if (nodoId == null) {
      _mostrarMensaje('No pudimos ubicar ese producto en el mapa de esta sucursal');
      return;
    }
    _calcularRutaHaciaNodo(nodoId);
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirMenuEntrada() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const MenuEntradaPopup(),
    );
  }

  void _irAHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  Future<void> _irAEscaner() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (codigo != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductResultScreen(barcode: codigo)),
      );
    }
  }

  void _irAlCarrito() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final nombreCorto = _nombreCortoSucursal[widget.sucursalId] ?? widget.sucursalId;

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: Column(
          children: [
            HeaderSirena(
              onMenuTap: _abrirMenuEntrada,
              onLogoTap: _irAHome,
              onBarcodeTap: _irAEscaner,
              onCartTap: _irAlCarrito,
              onSearchChanged: (_) {},
            ),
            Container(
              width: double.infinity,
              color: AppColors.azulSirena,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Sirena $nombreCorto',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: _cargandoGrafo
                  ? const Center(child: CircularProgressIndicator(color: AppColors.azulSirena))
                  : (_nodos.isEmpty ? _construirAvisoGrafoVacio() : _construirMapa()),
            ),
            _construirBarraEstado(),
            _construirBotonCarrito(),
          ],
        ),
      ),
    );
  }

  Widget _construirBarraEstado() {
    String mensaje;
    IconData? icono;
    Color? colorIcono;

    if (_hayRutaCalculada) {
      final mismaZona = _rutaActual.length == 1;
      mensaje = mismaZona ? 'Ya estás en la zona correcta' : 'Ruta calculada';
      icono = Icons.check_circle;
      colorIcono = Colors.green;
    } else if (_mostrarBuscador) {
      mensaje = 'Busca el producto o toca el pasillo al que quieres llegar';
    } else if (_esperandoOrigenManual) {
      return _construirAviso('Toca el mapa para marcar tu punto de partida');
    } else {
      return _construirAviso('Toca el mapa o presiona "Calcular ruta con mi carrito" para comenzar');
    }

    return Container(
      width: double.infinity,
      color: AppColors.blanco,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) Icon(icono, color: colorIcono, size: 20),
              if (icono != null) const SizedBox(width: 6),
              Flexible(
                child: Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: _reiniciarSeleccion,
              icon: const Icon(Icons.close, color: AppColors.azulSirena, size: 18),
              label: const Text(
                'Quitar selección',
                style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAviso(String texto) {
    return Container(
      width: double.infinity,
      color: AppColors.amarilloSirena,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.negro, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _construirAvisoGrafoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Todavía no hay grafo cargado para esta sucursal en Firebase '
                  '(sucursales/${widget.sucursalId}/grafo/nodos está vacío). '
                  'Corre cargarGrafoSanIsidro() una vez desde main.dart.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirMapa() {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Center(
              child: AspectRatio(
                aspectRatio: _aspectRatioMapa,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset('assets/mapas/${widget.sucursalId}.png', fit: BoxFit.contain),
                    ),
                    if (_rutaActual.length > 1)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RutaPainter(
                            puntos: _rutaActual.map((id) => _nodos[id]).whereType<NodoGrafo>().toList(),
                            color: AppColors.azulSirena,
                          ),
                        ),
                      ),
                    ..._construirEtiquetasPasillo(),
                    ..._construirNodosTactiles(),
                    ..._construirCajas(),
                    ..._construirMarcadoresDestino(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_mostrarBuscador) _construirBuscador(),
      ],
    );
  }

  List<Widget> _construirEtiquetasPasillo() {
    final etiquetas = CategoriaNodoMap.etiquetasPorPasillo(widget.sucursalId);
    final widgets = <Widget>[];

    for (final nodo in _nodos.values) {
      if (nodo.tipo != 'pasillo') continue;
      final etiqueta = etiquetas[nodo.id];
      if (etiqueta == null) continue;

      final ajuste = CategoriaNodoMap.ajusteEtiqueta(widget.sucursalId, nodo.id);
      final x = nodo.x + ajuste.dx;
      final y = nodo.y + ajuste.dy;

      widgets.add(
        Positioned.fill(
          child: Align(
            alignment: Alignment(x * 2 - 1, y * 2 - 1),
            child: GestureDetector(
              onTap: () => _onTapNodo(nodo.id),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  etiqueta,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: AppColors.negro,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _construirNodosTactiles() {
    final widgets = <Widget>[];

    for (final nodo in _nodos.values) {
      if (nodo.id.startsWith('corredor')) continue;
      if (nodo.tipo == 'caja') continue;

      final esOrigen = nodo.id == _origenId;
      final tamano = nodo.tipo == 'pasillo' ? 26.0 : 32.0;

      widgets.add(
        Positioned.fill(
          child: Align(
            alignment: Alignment(nodo.x * 2 - 1, nodo.y * 2 - 1),
            child: GestureDetector(
              onTap: () => _onTapNodo(nodo.id),
              child: Container(
                width: tamano,
                height: tamano,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esOrigen ? AppColors.azulSirena : AppColors.blanco.withOpacity(0.12),
                  border: Border.all(
                    color: AppColors.azulSirena,
                    width: (_esperandoOrigenManual && !esOrigen) ? 2 : 1.5,
                  ),
                ),
                child: esOrigen
                    ? const Icon(Icons.person_pin_circle, size: 16, color: AppColors.blanco)
                    : null,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  /// Marcadores numerados de las paradas del recorrido: círculo azul sólido
  /// con el número en blanco para cada parada del CUERPO de la ruta, y un
  /// pin (sin número, es la última) para el destino final.
  List<Widget> _construirMarcadoresDestino() {
    final widgets = <Widget>[];

    for (int i = 0; i < _destinosEnOrden.length; i++) {
      final nodo = _nodos[_destinosEnOrden[i]];
      if (nodo == null) continue;

      final esUltimo = i == _destinosEnOrden.length - 1;

      widgets.add(
        Positioned.fill(
          child: Align(
            alignment: Alignment(nodo.x * 2 - 1, nodo.y * 2 - 1),
            child: esUltimo ? _marcadorFlechaFinal() : _marcadorCirculoParada('${i + 1}'),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _marcadorCirculoParada(String numero) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.azulSirena,
      ),
      alignment: Alignment.center,
      child: Text(
        numero,
        style: const TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _marcadorFlechaFinal() {
    return const Icon(Icons.location_on, size: 34, color: AppColors.azulSirena);
  }

  List<Widget> _construirCajas() {
    final nodosCajas = _nodos.values.where((n) => n.tipo == 'caja');
    return nodosCajas.map((nodo) {
      final data = _cajas[nodo.id] as Map<dynamic, dynamic>?;
      final habilitada = (data?['habilitada'] as bool?) ?? true;
      final numero = nodo.id.replaceAll('caja', '');

      return Positioned.fill(
        child: Align(
          alignment: Alignment(nodo.x * 2 - 1, nodo.y * 2 - 1),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: habilitada ? Colors.green : Colors.red,
              border: Border.all(color: AppColors.blanco, width: 1.5),
            ),
            child: Center(
              child: Text(
                numero,
                style: const TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _construirBuscador() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: const BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(color: AppColors.sombraSuave, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _busquedaController,
              onChanged: _buscarProducto,
              decoration: InputDecoration(
                hintText: '¿Qué producto buscas? (o toca el pasillo directo)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            if (_buscando)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppColors.azulSirena),
              ),
            if (!_buscando)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _resultadosBusqueda.length,
                  itemBuilder: (context, index) {
                    final producto = _resultadosBusqueda[index];
                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text(producto.categoria),
                      onTap: () => _seleccionarProductoDestino(producto),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirBotonCarrito() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _calcularRutaConCarrito,
          icon: const Icon(Icons.shopping_cart, color: AppColors.blanco),
          label: const Text(
            'Calcular ruta con mi carrito',
            style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.azulSirena,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

class _RutaPainter extends CustomPainter {
  final List<NodoGrafo> puntos;
  final Color color;

  _RutaPainter({required this.puntos, required this.color});

  bool _esCorredor(NodoGrafo n) => n.tipo == 'interseccion';

  List<Offset> _construirOffsets(Size size) {
    Offset off(NodoGrafo n) => Offset(n.x * size.width, n.y * size.height);

    final resultado = <Offset>[off(puntos.first)];
    int i = 0;
    while (i < puntos.length - 1) {
      final anclaAntes = puntos[i];

      int j = i + 1;
      final corredores = <NodoGrafo>[];
      while (j < puntos.length && _esCorredor(puntos[j])) {
        corredores.add(puntos[j]);
        j++;
      }

      if (corredores.isEmpty) {
        resultado.add(off(puntos[j]));
        i = j;
        continue;
      }

      if (j >= puntos.length) {
        for (final c in corredores) {
          resultado.add(off(c));
        }
        i = j;
        continue;
      }

      final anclaDespues = puntos[j];

      if (corredores.length == 1) {
        final y = corredores[0].y * size.height;
        resultado.add(Offset(anclaAntes.x * size.width, y));
        resultado.add(Offset(anclaDespues.x * size.width, y));
      } else {
        resultado.add(Offset(anclaAntes.x * size.width, corredores.first.y * size.height));
        for (final c in corredores) {
          resultado.add(off(c));
        }
        resultado.add(Offset(anclaDespues.x * size.width, corredores.last.y * size.height));
      }

      resultado.add(off(anclaDespues));
      i = j;
    }

    return resultado;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final offsets = _construirOffsets(size);
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final punto in offsets.skip(1)) {
      path.lineTo(punto.dx, punto.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RutaPainter oldDelegate) => oldDelegate.puntos != puntos;
}