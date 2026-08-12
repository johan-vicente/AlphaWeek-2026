import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
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

  bool _isPermissionGranted = false;
  bool _isLoadingPermission = true;
  bool _isProcessingCode = false; // Previene lecturas duplicadas continuas

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  /// Solicita y verifica el permiso de cámara
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
      _isLoadingPermission = false;
    });
  }

  /// Maneja la captura del código de barras
  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessingCode) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _isProcessingCode = true;
        });

        final String scannedCode = barcode.rawValue!;

        // Detener el escáner al encontrar un código
        _scannerController.stop();

        // Retornar el código a la pantalla anterior o navegar al detalle
        Navigator.pop(context, scannedCode);
        break;
      }
    }
  }

  /// Diálogo para la entrada manual del código
  void _showManualInputDialog() {
    final TextEditingController manualCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entrada manual'),
          content: TextField(
            controller: manualCodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Ingresa el código EAN-13 o UPC',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = manualCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pop(context, code); // Retorna el código a la vista previa
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Producto'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingPermission) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isPermissionGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Se requiere permiso de cámara para escanear productos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkCameraPermission,
                child: const Text('Conceder Permiso'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showManualInputDialog,
                child: const Text('Ingresar código manualmente'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 1. Feed de la cámara
        MobileScanner(
          controller: _scannerController,
          onDetect: _onBarcodeDetected,
        ),

        // 2. Máscara visual con visor centrado
        CustomPaint(
          painter: ScannerOverlayPainter(),
          child: const SizedBox.expand(),
        ),

        // 3. Indicaciones e Ingreso manual inferior
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Apunta la cámara al código de barras',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _showManualInputDialog,
                icon: const Icon(Icons.keyboard),
                label: const Text('¿Problemas para escanear? Entrada manual'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Diseña el marco de escaneo (cuadro delimitador visual)
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

    // Fondo semitransparente oscuro
    final Paint backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Borde del cuadro de escaneo
    final Paint borderPaint = Paint()
      ..color = Colors.greenAccent
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