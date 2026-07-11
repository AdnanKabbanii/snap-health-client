import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerService {
  final _scanner = BarcodeScanner(formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upca, BarcodeFormat.upce]);

  Future<String?> detectBarcode(Uint8List imageBytes) async {
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: const Size(1080, 1920),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 1080,
      ),
    );

    try {
      final barcodes = await _scanner.processImage(inputImage);
      for (final barcode in barcodes) {
        if (barcode.rawValue != null && barcode.rawValue!.length >= 8) {
          return barcode.rawValue;
        }
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _scanner.close();
  }
}

final barcodeService = BarcodeScannerService();
