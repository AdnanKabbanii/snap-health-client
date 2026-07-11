import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class FoodClassifier {
  final _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  static const _categoryMap = {
    'food': 'food',
    'fruit': 'food',
    'vegetable': 'food',
    'meat': 'food',
    'bread': 'food',
    'dessert': 'food',
    'snack': 'food',
    'drink': 'beverage',
    'beverage': 'beverage',
    'bottle': 'beverage',
    'juice': 'beverage',
    'coffee': 'beverage',
    'tea': 'beverage',
    'pill': 'supplement',
    'medicine': 'supplement',
    'vitamin': 'supplement',
    'cosmetics': 'skincare',
    'cream': 'skincare',
    'lotion': 'skincare',
    'lamp': 'lighting',
    'light': 'lighting',
    'bulb': 'lighting',
    'electronics': 'electronics',
    'device': 'electronics',
  };

  Future<String?> classify(Uint8List imageBytes) async {
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
        final key = label.label.toLowerCase();
        for (final entry in _categoryMap.entries) {
          if (key.contains(entry.key)) return entry.value;
        }
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _labeler.close();
  }
}

final foodClassifier = FoodClassifier();
