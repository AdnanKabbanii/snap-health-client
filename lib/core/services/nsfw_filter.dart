import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class NsfwFilter {
  final _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));

  static const _blockedLabels = {'nude', 'nudity', 'adult', 'explicit', 'sexual'};

  Future<bool> isNsfw(Uint8List imageBytes) async {
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
      final labels = await _labeler.processImage(inputImage);
      for (final label in labels) {
        if (_blockedLabels.contains(label.label.toLowerCase())) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  void dispose() {
    _labeler.close();
  }
}

final nsfwFilter = NsfwFilter();
