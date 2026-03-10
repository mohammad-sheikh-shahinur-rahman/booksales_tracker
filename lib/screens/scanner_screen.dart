import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'বারকোড স্ক্যান করুন',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Torch control with reactive UI
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final torchState = state.torchState;
              return IconButton(
                iconSize: 32,
                color: Colors.white,
                icon: Icon(
                  torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: torchState == TorchState.on ? Colors.yellow : Colors.grey,
                ),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          // Camera facing control
          IconButton(
            iconSize: 32,
            color: Colors.white,
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Consumer(
        builder: (context, ref, child) {
          return Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      final foundBook = ref
                          .read(inventoryProvider.notifier)
                          .findByBarcode(barcode.rawValue!);
                      if (foundBook != null) {
                        cameraController.stop();
                        Navigator.pop(context, foundBook);
                        return;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'বারকোড: ${barcode.rawValue} - বই পাওয়া যায়নি!',
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              _buildScannerOverlay(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size(250, 250),
            painter: ScannerBorderPainter(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'বইয়ের বারকোডটি ফ্রেমের ভেতরে রাখুন',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    double cornerSize = 40;

    path.moveTo(0, cornerSize);
    path.lineTo(0, 0);
    path.lineTo(cornerSize, 0);

    path.moveTo(size.width - cornerSize, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerSize);

    path.moveTo(size.width, size.height - cornerSize);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - cornerSize, size.height);

    path.moveTo(cornerSize, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - cornerSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
