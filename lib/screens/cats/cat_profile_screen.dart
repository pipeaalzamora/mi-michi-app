import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../data/life_stages.dart';
import '../../models/health_log.dart';
import '../../widgets/cat_share_card.dart';
import '../../widgets/cat_avatar_visual.dart';
import 'cat_gallery_screen.dart';

// Datos demo para estadísticas
final _demoLogs = [
  HealthLog(
      id: 'h1',
      catId: 'cat-1',
      userId: 'demo-user',
      logType: 'peso',
      logDate: '2026-04-01',
      numericValue: 4.0,
      title: '4.0 kg',
      createdAt: DateTime(2026, 4, 1),
      updatedAt: DateTime(2026, 4, 1)),
  HealthLog(
      id: 'h2',
      catId: 'cat-1',
      userId: 'demo-user',
      logType: 'peso',
      logDate: '2026-04-15',
      numericValue: 4.2,
      title: '4.2 kg',
      createdAt: DateTime(2026, 4, 15),
      updatedAt: DateTime(2026, 4, 15)),
  HealthLog(
      id: 'h3',
      catId: 'cat-1',
      userId: 'demo-user',
      logType: 'visita_vet',
      logDate: '2026-03-10',
      title: 'Revisión anual',
      createdAt: DateTime(2026, 3, 10),
      updatedAt: DateTime(2026, 3, 10)),
  HealthLog(
      id: 'h4',
      catId: 'cat-1',
      userId: 'demo-user',
      logType: 'medicamento',
      logDate: '2026-02-20',
      title: 'Antiparasitario',
      createdAt: DateTime(2026, 2, 20),
      updatedAt: DateTime(2026, 2, 20)),
];

class CatProfileScreen extends ConsumerWidget {
  final String catId;
  const CatProfileScreen({super.key, required this.catId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catsProvider).cats.firstWhere(
          (c) => c.id == catId,
          orElse: () => throw StateError('Cat not found'),
        );
    final catTheme = ref.watch(catThemeProvider);
    final stage = LifeStages.calculate(cat.birthDate);
    final age = LifeStages.formatAge(cat.birthDate);
    final shareKey = GlobalKey();

    // Estadísticas demo
    final vetVisits = _demoLogs.where((l) => l.logType == 'visita_vet').length;
    final lastWeight = _demoLogs
        .where((l) => l.logType == 'peso' && l.numericValue != null)
        .toList()
      ..sort((a, b) => b.logDate.compareTo(a.logDate));
    final daysSinceWeight = lastWeight.isNotEmpty
        ? DateTime.now()
            .difference(DateTime.parse(lastWeight.first.logDate))
            .inDays
        : null;
    final lastDeworming = _demoLogs
        .where((l) => l.logType == 'medicamento')
        .toList()
      ..sort((a, b) => b.logDate.compareTo(a.logDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        actions: [
          // Compartir
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () =>
                _showShareDialog(context, cat.name, shareKey, catTheme, cat),
          ),
          // Galería
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CatGalleryScreen(catName: cat.name, catId: catId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/cats/$catId/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero del gato
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: catTheme.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CatAvatarVisual(cat: cat, height: 190),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      Text(cat.name,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text(age,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15)),
                      if (stage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('${stage.emoji} ${stage.label}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Estadísticas ──────────────────────────────────────
          Row(
            children: [
              _StatCard(
                emoji: '🩺',
                label: 'Visitas al vet',
                value: '$vetVisits',
                color: const Color(0xFFEDE9FE),
              ),
              const SizedBox(width: 10),
              _StatCard(
                emoji: '⚖️',
                label: 'Último peso',
                value: lastWeight.isNotEmpty ? 'Hace ${daysSinceWeight}d' : '—',
                color: const Color(0xFFD1FAE5),
              ),
              const SizedBox(width: 10),
              _StatCard(
                emoji: '💊',
                label: 'Última desparasit.',
                value: lastDeworming.isNotEmpty
                    ? 'Hace ${DateTime.now().difference(DateTime.parse(lastDeworming.first.logDate)).inDays}d'
                    : '—',
                color: const Color(0xFFFFE4E6),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Datos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sus datos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _DataRow('Sexo', cat.sex == 'desconocido' ? '—' : cat.sex),
                  _DataRow('Raza', cat.breed ?? '—'),
                  _DataRow('Color', cat.color ?? '—'),
                  _DataRow('Peso',
                      cat.weightKg != null ? '${cat.weightKg} kg' : '—'),
                  _DataRow('Nacimiento', cat.birthDate ?? '—'),
                  if (cat.notes != null) ...[
                    const Divider(height: 20),
                    Text('Notas',
                        style:
                            TextStyle(fontSize: 12, color: context.softText)),
                    const SizedBox(height: 4),
                    Text(cat.notes!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Etapa de vida
          if (stage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.softTint(const Color(0xFFEDE9FE)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.appBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(stage.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stage.label,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: context.isDarkMode
                                      ? const Color(0xFFE9D5FF)
                                      : const Color(0xFF4C1D95))),
                          Text(stage.ageRange,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.isDarkMode
                                      ? const Color(0xFFC4B5FD)
                                      : const Color(0xFF7C3AED))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(stage.description,
                      style: TextStyle(
                          color: context.isDarkMode
                              ? const Color(0xFFE9D5FF)
                              : const Color(0xFF4C1D95))),
                  const SizedBox(height: 12),
                  Text('Tips para esta etapa',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.isDarkMode
                              ? const Color(0xFFE9D5FF)
                              : const Color(0xFF4C1D95))),
                  const SizedBox(height: 6),
                  ...stage.tips.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: AppTheme.primary)),
                            Expanded(
                                child: Text(t,
                                    style: TextStyle(
                                        color: context.isDarkMode
                                            ? const Color(0xFFE9D5FF)
                                            : const Color(0xFF4C1D95),
                                        fontSize: 13))),
                          ],
                        ),
                      )),
                  Divider(color: context.appBorder, height: 20),
                  Text('Veterinario',
                      style: TextStyle(
                          fontSize: 12,
                          color: context.isDarkMode
                              ? const Color(0xFFC4B5FD)
                              : const Color(0xFF7C3AED))),
                  Text(stage.vetVisits,
                      style: TextStyle(
                          color: context.isDarkMode
                              ? const Color(0xFFE9D5FF)
                              : const Color(0xFF4C1D95))),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Accesos rápidos
          Row(
            children: [
              _ProfileAction(
                  label: 'Salud',
                  icon: Icons.favorite_outline,
                  color: const Color(0xFFFFE4E6),
                  onTap: () => context.push('/health')),
              const SizedBox(width: 12),
              _ProfileAction(
                  label: 'Vacunas',
                  icon: Icons.vaccines_outlined,
                  color: const Color(0xFFEDE9FE),
                  onTap: () => context.push('/vaccines')),
              const SizedBox(width: 12),
              _ProfileAction(
                  label: 'Fotos',
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFD1FAE5),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CatGalleryScreen(
                              catName: cat.name, catId: catId)))),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareDialog(
      BuildContext context, String catName, GlobalKey shareKey, catTheme, cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Compartir tarjeta'),
        content:
            CatShareCard(cat: cat, catTheme: catTheme, repaintKey: shareKey),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await shareCatCard(shareKey, catName);
            },
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.softTint(color),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appBorder.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(label,
                style: TextStyle(fontSize: 10, color: context.softText),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.softText)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ProfileAction(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.softTint(color),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appBorder.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
