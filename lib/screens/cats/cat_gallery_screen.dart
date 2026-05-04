import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

/// Modelo de foto de la galería (demo: solo locales)
class CatPhoto {
  final String id;
  final String? url;      // URL remota (cuando haya backend)
  final File? localFile;  // Archivo local recién tomado
  final DateTime date;
  final String? caption;

  const CatPhoto({
    required this.id,
    this.url,
    this.localFile,
    required this.date,
    this.caption,
  });
}

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
  // En demo las fotos viven en memoria
  final List<CatPhoto> _photos = [];
  final _picker = ImagePicker();

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
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

    setState(() {
      _photos.insert(
        0,
        CatPhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          localFile: File(picked.path),
          date: DateTime.now(),
        ),
      );
    });
  }

  void _viewPhoto(CatPhoto photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(photo: photo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotos de ${widget.catName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: _addPhoto,
          ),
        ],
      ),
      body: _photos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📷', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text('Aún no hay fotos',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Toca + para añadir la primera',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Añadir foto'),
                  ),
                ],
              ),
            )
          : GridView.builder(
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
                      child: photo.localFile != null
                          ? Image.file(photo.localFile!, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: photo.url!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final CatPhoto photo;
  const _PhotoViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _formatDate(photo.date),
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
      body: Center(
        child: Hero(
          tag: photo.id,
          child: InteractiveViewer(
            child: photo.localFile != null
                ? Image.file(photo.localFile!)
                : CachedNetworkImage(
                    imageUrl: photo.url!,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
