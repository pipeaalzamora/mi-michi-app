import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cat.dart';
import '../../data/cat_breeds.dart';
import '../../services/cats_service.dart';
import '../../services/integrations_service.dart';

class CatFormScreen extends ConsumerStatefulWidget {
  final String? catId;
  const CatFormScreen({super.key, this.catId});

  @override
  ConsumerState<CatFormScreen> createState() => _CatFormScreenState();
}

class _CatFormScreenState extends ConsumerState<CatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _sex = 'desconocido';
  String? _birthDate;
  String? _photoUrl;
  File? _localPhoto;
  bool _saving = false;
  bool _uploading = false;
  bool _loadingBreeds = false;
  List<String> _breedOptions = catBreeds;

  Cat? get _existing {
    if (widget.catId == null) return null;
    return ref.read(catsProvider).cats.firstWhere(
          (c) => c.id == widget.catId,
          orElse: () => throw StateError('Cat not found'),
        );
  }

  @override
  void initState() {
    super.initState();
    final cat = _existing;
    if (cat != null) {
      _nameCtrl.text = cat.name;
      _breedCtrl.text = cat.breed ?? '';
      _colorCtrl.text = cat.color ?? '';
      _weightCtrl.text = cat.weightKg?.toString() ?? '';
      _notesCtrl.text = cat.notes ?? '';
      _sex = cat.sex;
      _birthDate = cat.birthDate;
      _photoUrl = cat.photoUrl;
    }
    _loadBreeds();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _colorCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _localPhoto = File(picked.path));
  }

  Future<void> _loadBreeds() async {
    setState(() => _loadingBreeds = true);
    try {
      final breeds = await IntegrationsService.catBreeds();
      final names = breeds
          .map((breed) => breed.name)
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (mounted && names.isNotEmpty) {
        setState(() => _breedOptions = names);
      }
    } catch (_) {
      if (mounted) setState(() => _breedOptions = catBreeds);
    } finally {
      if (mounted) setState(() => _loadingBreeds = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      Cat cat;
      if (widget.catId == null) {
        cat = await CatsService.create(
          name: _nameCtrl.text.trim(),
          birthDate: _birthDate,
          breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
          sex: _sex,
          color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
          weightKg: double.tryParse(_weightCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      } else {
        cat = await CatsService.update(
          id: widget.catId!,
          name: _nameCtrl.text.trim(),
          birthDate: _birthDate,
          breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
          sex: _sex,
          color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
          weightKg: double.tryParse(_weightCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      // Subir foto si se seleccionó una nueva
      if (_localPhoto != null) {
        setState(() => _uploading = true);
        await CatsService.uploadPhoto(cat.id, _localPhoto!);
        setState(() => _uploading = false);
      }

      await ref.read(catsProvider.notifier).refresh();
      if (widget.catId == null) {
        ref.read(catsProvider.notifier).setActiveCat(cat.id);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _uploading = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: const Text('¿Seguro que quieres eliminar este perfil?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await CatsService.delete(widget.catId!);
      await ref.read(catsProvider.notifier).refresh();
      if (mounted) context.go('/cats');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.catId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nuevo gatito' : 'Editar gato'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Foto
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      backgroundImage: _localPhoto != null
                          ? FileImage(_localPhoto!)
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!) as ImageProvider
                              : null),
                      child: (_localPhoto == null && _photoUrl == null)
                          ? const Icon(Icons.camera_alt,
                              size: 32, color: AppTheme.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),

            // Fecha de nacimiento
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate != null
                      ? DateTime.parse(_birthDate!)
                      : DateTime.now().subtract(const Duration(days: 365)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() =>
                      _birthDate = picked.toIso8601String().split('T').first);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  controller: TextEditingController(text: _birthDate ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sexo
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const [
                DropdownMenuItem(value: 'macho', child: Text('Macho')),
                DropdownMenuItem(value: 'hembra', child: Text('Hembra')),
                DropdownMenuItem(value: 'desconocido', child: Text('No sé')),
              ],
              onChanged: (v) => setState(() => _sex = v!),
            ),
            const SizedBox(height: 12),

            // Peso
            TextFormField(
              controller: _weightCtrl,
              decoration: const InputDecoration(
                  labelText: 'Peso (kg)', suffixText: 'kg'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),

            // Raza
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _breedCtrl.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return _breedOptions;
                return _breedOptions.where((b) => b
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (value) => _breedCtrl.text = value,
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                // Sincronizar con _breedCtrl al abrir el form
                if (controller.text.isEmpty && _breedCtrl.text.isNotEmpty) {
                  controller.text = _breedCtrl.text;
                }
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Raza',
                    suffixIcon: _loadingBreeds
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (v) => _breedCtrl.text = v,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 200, maxWidth: 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (_, i) {
                          final option = options.elementAt(i);
                          return ListTile(
                            dense: true,
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Color
            TextFormField(
              controller: _colorCtrl,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 12),

            // Notas
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving || _uploading ? null : _save,
              child: _saving || _uploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isNew ? 'Añadir gatito' : 'Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
