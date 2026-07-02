import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/cat.dart';
import '../data/life_stages.dart';
import '../core/theme/cat_theme.dart';

class CatShareCard extends StatelessWidget {
  final Cat cat;
  final CatTheme catTheme;
  final GlobalKey repaintKey;

  const CatShareCard({
    super.key,
    required this.cat,
    required this.catTheme,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final stage = LifeStages.calculate(cat.birthDate);
    final age = LifeStages.formatAge(cat.birthDate);

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: catTheme.heroGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              backgroundImage:
                  cat.photoUrl != null ? NetworkImage(cat.photoUrl!) : null,
              child: cat.photoUrl == null
                  ? Text(
                      cat.name.characters.take(2).toString().toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(cat.name,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            Text(age,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            if (stage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${stage.emoji} ${stage.label}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 16),
            // Datos
            _InfoRow('Raza', cat.breed ?? '—'),
            _InfoRow('Sexo', cat.sex == 'desconocido' ? '—' : cat.sex),
            if (cat.weightKg != null) _InfoRow('Peso', '${cat.weightKg} kg'),
            const SizedBox(height: 12),
            const Text('Mi Michi 🐾',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

/// Captura el widget y lo comparte como imagen PNG.
Future<void> shareCatCard(GlobalKey repaintKey, String catName) async {
  try {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/michi_$catName.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '¡Mira a $catName en Mi Michi! 🐾',
      ),
    );
  } catch (e) {
    debugPrint('Error sharing: $e');
  }
}
