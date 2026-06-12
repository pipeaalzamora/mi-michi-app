import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/adoption_cat.dart';
import '../../services/integrations_service.dart';

class AdoptionsScreen extends StatefulWidget {
  const AdoptionsScreen({super.key});

  @override
  State<AdoptionsScreen> createState() => _AdoptionsScreenState();
}

class _AdoptionsScreenState extends State<AdoptionsScreen> {
  final _locationCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  List<AdoptionCat> _cats = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _cats = [];
    });
    try {
      final cats = await IntegrationsService.adoptableCats(
        location: _locationCtrl.text,
        breed: _breedCtrl.text,
      );
      if (mounted) setState(() => _cats = cats);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopciones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Ciudad, estado o código postal',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _breedCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Raza opcional',
                    prefixIcon: Icon(Icons.pets_outlined),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _search,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Buscar gatos'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 18),
            _MessageState(
              icon: Icons.key_off_outlined,
              message: _error!,
            ),
          ] else if (!_loading && _cats.isEmpty) ...[
            const SizedBox(height: 90),
            const _MessageState(
              icon: Icons.volunteer_activism_outlined,
              message: 'Busca gatos disponibles por ubicación.',
            ),
          ],
          const SizedBox(height: 14),
          ..._cats.map((cat) => _AdoptionCard(cat: cat)),
        ],
      ),
    );
  }
}

class _AdoptionCard extends StatelessWidget {
  final AdoptionCat cat;

  const _AdoptionCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cat.photos.isEmpty
                ? Container(
                    width: 96,
                    height: 110,
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(Icons.pets_outlined,
                        color: AppTheme.primary),
                  )
                : CachedNetworkImage(
                    imageUrl: cat.photos.first,
                    width: 96,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900)),
                Text(
                  [
                    if (cat.age.isNotEmpty) cat.age,
                    if (cat.gender.isNotEmpty) cat.gender,
                    if (cat.size.isNotEmpty) cat.size,
                  ].join(' · '),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (cat.breeds.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(cat.breeds.join(', '),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
                if (cat.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    cat.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                if (cat.contact.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    cat.contact,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 44, color: Colors.grey),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
