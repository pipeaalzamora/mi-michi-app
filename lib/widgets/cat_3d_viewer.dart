import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../data/cat_models.dart';

class Cat3DViewer extends StatelessWidget {
  final String? color;
  final String? breed;
  final double height;
  final bool autoRotate;
  final bool showControls;

  const Cat3DViewer({
    super.key,
    this.color,
    this.breed,
    this.height = 300,
    this.autoRotate = true,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    final modelPath = CatModelSelector.selectModel(color: color, breed: breed);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ModelViewer(
          src: modelPath,
          alt: 'Modelo 3D del gato',
          autoRotate: autoRotate,
          autoPlay: true,
          cameraControls: showControls,
          shadowIntensity: 1,
          backgroundColor: Colors.transparent,
          // Iluminación suave
          environmentImage: 'neutral',
          exposure: 1.0,
        ),
      ),
    );
  }
}

/// Versión compacta para el home card
class Cat3DViewerCompact extends StatelessWidget {
  final String? color;
  final String? breed;

  const Cat3DViewerCompact({super.key, this.color, this.breed});

  @override
  Widget build(BuildContext context) {
    return Cat3DViewer(
      color: color,
      breed: breed,
      height: 200,
      autoRotate: true,
      showControls: false,
    );
  }
}
