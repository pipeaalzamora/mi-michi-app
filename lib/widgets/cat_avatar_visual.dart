import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/cat.dart';

class CatAvatarVisual extends StatelessWidget {
  final Cat cat;
  final double height;

  const CatAvatarVisual({
    super.key,
    required this.cat,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (cat.photoUrl != null && cat.photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: cat.photoUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _FallbackAvatar(cat: cat, height: height),
        errorWidget: (_, __, ___) => _FallbackAvatar(cat: cat, height: height),
      );
    }
    return _FallbackAvatar(cat: cat, height: height);
  }
}

class _FallbackAvatar extends StatelessWidget {
  final Cat cat;
  final double height;

  const _FallbackAvatar({required this.cat, required this.height});

  @override
  Widget build(BuildContext context) {
    final initials = cat.name.trim().isEmpty
        ? '?'
        : cat.name.trim().split(RegExp(r'\s+')).take(2).map((part) {
            return part.substring(0, 1).toUpperCase();
          }).join();

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Container(
        width: height * 0.58,
        height: height * 0.58,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, color: AppTheme.primary, size: 28),
            const SizedBox(height: 2),
            Text(
              initials,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
