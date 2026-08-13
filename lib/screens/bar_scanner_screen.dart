import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'variable_weight_dialog.dart';

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

  void _showManualInputDialog() {
    final TextEditingController manualCodeController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = manualCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogContext, code);
                }
              },
              child: const Text('Aceptar'),
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context, result);
        }
      });
    }
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
                final isTorchOn = state.torchState == TorchState.on;
                return Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? Colors.yellow : Colors.grey,
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
            bottom: 30,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _showManualInputDialog,
                        icon: const Icon(Icons.keyboard, size: 18),
                        label: const Text('Manual', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _showVariableWeightModal,
                        icon: const Icon(Icons.scale, size: 18),
                        label: const Text('Por Peso (lb)', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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