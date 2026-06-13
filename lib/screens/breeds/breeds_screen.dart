import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../data/cat_breed_localizations.dart';
import '../../models/cat_breed_info.dart';
import '../../models/external_cat_content.dart';
import '../../services/integrations_service.dart';

class BreedsScreen extends StatefulWidget {
  const BreedsScreen({super.key});

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  final _searchCtrl = TextEditingController();
  List<CatBreedInfo> _breeds = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final breeds = await IntegrationsService.catBreeds();
      if (mounted) {
        setState(() {
          _breeds = breeds;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = CatBreedLocalizations.searchable(_searchCtrl.text.trim());
    final filtered = _breeds.where((breed) {
      if (query.isEmpty) return true;
      final localized = CatBreedLocalizations.from(breed);
      final sourceText = CatBreedLocalizations.searchable(
        '${breed.name} ${breed.origin} ${breed.temperament}',
      );
      return localized.searchText.contains(query) || sourceText.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Razas')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar por raza, origen o temperamento',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorState(message: _error!, onRetry: _load)
            else if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: Text('No hay razas con ese filtro')),
              )
            else
              ...filtered.map((breed) => _BreedTile(
                    breed: breed,
                    onTap: () => _showBreedDetails(context, breed),
                  )),
          ],
        ),
      ),
    );
  }

  void _showBreedDetails(BuildContext context, CatBreedInfo breed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _BreedDetailsSheet(breed: breed),
    );
  }
}

class _BreedTile extends StatelessWidget {
  final CatBreedInfo breed;
  final VoidCallback onTap;

  const _BreedTile({required this.breed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localized = CatBreedLocalizations.from(breed);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: context.cardFill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    localized.name.isEmpty
                        ? '?'
                        : localized.name.substring(0, 1),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localized.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (localized.origin.isNotEmpty) localized.origin,
                          if (breed.lifeSpan.isNotEmpty)
                            '${breed.lifeSpan} años',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.softText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreedDetailsSheet extends StatefulWidget {
  final CatBreedInfo breed;

  const _BreedDetailsSheet({required this.breed});

  @override
  State<_BreedDetailsSheet> createState() => _BreedDetailsSheetState();
}

class _BreedDetailsSheetState extends State<_BreedDetailsSheet> {
  late final Future<List<CatImageInfo>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture =
        IntegrationsService.catBreedImages(widget.breed.id, limit: 8);
  }

  @override
  Widget build(BuildContext context) {
    final breed = widget.breed;
    final localized = CatBreedLocalizations.from(breed);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            localized.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (localized.origin.isNotEmpty) localized.origin,
              if (breed.weightMetric.isNotEmpty) '${breed.weightMetric} kg',
              if (breed.lifeSpan.isNotEmpty) '${breed.lifeSpan} años',
            ].join(' · '),
            style: TextStyle(color: context.softText),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<CatImageInfo>>(
            future: _imagesFuture,
            builder: (context, snapshot) {
              final images = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 170,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (images.isEmpty) return const SizedBox();
              return SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: images[i].url,
                      width: 220,
                      height: 170,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 220,
                        color: context.placeholderFill,
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            localized.description,
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (localized.temperaments.isNotEmpty)
                ...localized.temperaments
                    .take(6)
                    .map((tag) => _InfoChip(label: tag)),
              if (breed.hypoallergenic)
                const _InfoChip(label: 'Hipoalergénico'),
            ],
          ),
          const SizedBox(height: 18),
          _ScoreRow(label: 'Energía', value: breed.energyLevel),
          _ScoreRow(label: 'Cariño', value: breed.affectionLevel),
          _ScoreRow(label: 'Niños', value: breed.childFriendly),
          _ScoreRow(label: 'Perros', value: breed.dogFriendly),
          _ScoreRow(label: 'Cuidado', value: breed.grooming),
          _ScoreRow(label: 'Inteligencia', value: breed.intelligence),
          _ScoreRow(label: 'Riesgo salud', value: breed.healthIssues),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value <= 0) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: TextStyle(color: context.softText)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value.clamp(0, 5) / 5,
                minHeight: 8,
                backgroundColor: context.chipFill,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value/5', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 42, color: context.softText),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.softText),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
