import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/producto.dart';
import '../utils/app_colors.dart';
import '../widgets/main_menu_popup.dart';
import 'variable_weight_dialog.dart';
import 'home_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isCameraActive = false;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );

  bool _isProcessingCode = false;

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessingCode) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _isProcessingCode = true;
        });

        final String scannedCode = barcode.rawValue!;
        _scannerController.stop();

        if (mounted) {
          Navigator.pop(context, scannedCode);
        }
        break;
      }
    }
  }

  // Se eliminó _abrirMenuPrincipal

  Future<void> _irAHome() async {
    if (_isCameraActive) {
      await _scannerController.stop();
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  void _showManualInputDialog() {
    final TextEditingController manualCodeController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.blanco,
          title: const Text(
            'Entrada manual',
            style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: manualCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ingresa el código de barra',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.amarilloSirena),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cianSirenaMas, width: 2),
              ),
              prefixIcon: const Icon(Icons.numbers, color: AppColors.azulSirena),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final code = manualCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogContext, code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulSirena,
                foregroundColor: AppColors.blanco,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ACEPTAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((code) {
      if (code != null && code.isNotEmpty && mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  void _showVariableWeightModal() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const VariableWeightDialog(),
    );

    if (result != null && mounted) {
      final Producto producto = result['producto'] as Producto;
      // El diálogo ya se cerró solo (su botón "AGREGAR" hace su propio
      // Navigator.pop). Aquí solo cerramos el escáner UNA vez, devolviendo
      // el código de barra — mismo contrato que un escaneo normal, sigue
      // el mismo camino hacia ProductResultScreen. Antes esto hacía un
      // SEGUNDO pop con el Map completo, lo que en realidad cerraba esta
      // pantalla del escáner devolviendo un tipo equivocado (Map en vez
      // de String), dejando el flujo roto para todo lo que viniera después.
      Navigator.pop(context, producto.codigoBarra);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Widget _buildIntroView() {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloSirena,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ESCANER SIRENA',
          style: TextStyle(
            color: AppColors.azulSirena,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.azulSirena),
            onPressed: _irAHome,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.azulSirena),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.barcode,
                size: 140,
                color: AppColors.azulSirena,
              ),
              const SizedBox(height: 32),
              const Text(
                'Escaner de Productos',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.negro,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '"Tu compra más rápida: descubre precios y la\nzona exactas de tus productos favoritos."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    setState(() {
                      _isCameraActive = true;
                    });
                    await _scannerController.start();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cianSirenaMas, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'ESCANEA AHORA',
                    style: TextStyle(
                      color: AppColors.cianSirenaMas,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _showManualInputDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.blanco,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.amarilloSirena, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amarilloSirena.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.keyboard_alt_outlined, color: AppColors.azulSirena, size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Manual',
                              style: TextStyle(
                                color: AppColors.azulSirena,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _showVariableWeightModal,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.blanco,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.amarilloSirena, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amarilloSirena.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.scale_outlined, color: AppColors.azulSirena, size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Por Peso',
                              style: TextStyle(
                                color: AppColors.azulSirena,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloSirena,
        title: const Text(
          'Escanear Producto',
          style: TextStyle(color: AppColors.azulSirena, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.azulSirena),
          onPressed: () async {
            await _scannerController.stop();
            setState(() {
              _isCameraActive = false;
            });
          },
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.azulSirena),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.azulSirena),
            onPressed: _irAHome,
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                final isTorchOn = state.torchState == TorchState.on;
                return Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? AppColors.azulSirena : Colors.grey,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _getErrorMessage(error.errorCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showManualInputDialog,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Ingresar código manualmente'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Apunta la cámara al código de barras',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isCameraActive ? _buildCameraView() : _buildIntroView();
  }

  String _getErrorMessage(MobileScannerErrorCode errorCode) {
    switch (errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Permiso de cámara denegado. Por favor concédelo en los ajustes de tu dispositivo.';
      case MobileScannerErrorCode.unsupported:
        return 'No se encontró una cámara disponible en este dispositivo.';
      default:
        return 'Ocurrió un error al cargar la cámara.';
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanBoxWidth = size.width * 0.8;
    final double scanBoxHeight = 200.0;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: scanBoxWidth,
      height: scanBoxHeight,
    );

    final Paint backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    final Paint borderPaint = Paint()
      ..color = AppColors.cianSirenaMas
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}