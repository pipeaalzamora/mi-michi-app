import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../models/cat_photo.dart';
import '../../services/photos_service.dart';

class CatGalleryScreen extends StatefulWidget {
  final String catName;
  final String catId;

  const CatGalleryScreen({
    super.key,
    required this.catName,
    required this.catId,
  });

  @override
  State<CatGalleryScreen> createState() => _CatGalleryScreenState();
}

class _CatGalleryScreenState extends State<CatGalleryScreen> {
  final List<CatPhoto> _photos = [];
  final _picker = ImagePicker();
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _loading = true);
    try {
      final photos = await PhotosService.list(widget.catId);
      if (mounted) {
        setState(() {
          _photos
            ..clear()
            ..addAll(photos);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final caption = await _askCaption();
    if (caption == null) return;

    setState(() => _uploading = true);
    try {
      final uploaded = await PhotosService.upload(
        widget.catId,
        File(picked.path),
        caption: caption,
      );
      if (mounted) {
        setState(() => _photos.insert(0, uploaded));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<String?> _askCaption() async {
    final controller = TextEditingController();
    final caption = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Texto de la foto'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Ej: Siesta en la ventana',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Sin texto'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Subir'),
          ),
        ],
      ),
    );
    controller.dispose();
    return caption;
  }

  void _viewPhoto(CatPhoto photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(
          photo: photo,
          onDelete: _deletePhoto,
        ),
      ),
    );
  }

  Future<void> _deletePhoto(CatPhoto photo) async {
    await PhotosService.delete(widget.catId, photo.id);
    if (mounted) {
      setState(() => _photos.removeWhere((p) => p.id == photo.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotos de ${widget.catName}'),
        actions: [
          IconButton(
            icon: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_a_photo_outlined),
            onPressed: _uploading ? null : _addPhoto,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_photos.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📷', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text('Aún no hay fotos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Toca + para añadir la primera',
                      style: TextStyle(color: context.softText)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Añadir foto'),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length,
              itemBuilder: (_, i) {
                final photo = _photos[i];
                return GestureDetector(
                  onTap: () => _viewPhoto(photo),
                  child: Hero(
                    tag: photo.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: photo.photoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: context.placeholderFill,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                          if (photo.caption.isNotEmpty)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                color: Colors.black54,
                                child: Text(
                                  photo.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (_uploading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.24),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final CatPhoto photo;
  final Future<void> Function(CatPhoto photo) onDelete;
  const _PhotoViewer({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          photo.caption.isNotEmpty
              ? photo.caption
              : _formatDate(photo.createdAt),
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar foto'),
                  content: const Text('¿Quieres eliminar esta foto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await onDelete(photo);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: photo.id,
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: photo.photoUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (photo.caption.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      photo.caption,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
