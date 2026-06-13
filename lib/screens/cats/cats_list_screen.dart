import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../data/life_stages.dart';
import '../../models/cat.dart';

class CatsListScreen extends ConsumerStatefulWidget {
  const CatsListScreen({super.key});

  @override
  ConsumerState<CatsListScreen> createState() => _CatsListScreenState();
}

class _CatsListScreenState extends ConsumerState<CatsListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final catsState = ref.watch(catsProvider);
    final filtered = catsState.cats
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis gatos'),
        actions: [
          IconButton(
            tooltip: 'Adopciones',
            icon: const Icon(Icons.volunteer_activism_outlined),
            onPressed: () => context.push('/adoptions'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/cats/new');
              ref.read(catsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar gato...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: catsState.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🐱', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              _search.isEmpty
                                  ? 'Aún no tienes gatos registrados'
                                  : 'No se encontró ningún gato',
                              style: TextStyle(color: context.softText),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CatCard(cat: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CatCard extends ConsumerWidget {
  final Cat cat;
  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = LifeStages.calculate(cat.birthDate);
    final age = LifeStages.formatAge(cat.birthDate);
    final isActive = ref.watch(catsProvider).activeCatId == cat.id;

    return GestureDetector(
      onTap: () => context.push('/cats/${cat.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? AppTheme.primary : context.appBorder,
              width: isActive ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: context.softShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              backgroundImage:
                  cat.photoUrl != null ? NetworkImage(cat.photoUrl!) : null,
              child: cat.photoUrl == null
                  ? Text(
                      cat.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(age,
                      style: TextStyle(color: context.softText, fontSize: 13)),
                  if (stage != null)
                    Text('${stage.emoji} ${stage.label}',
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Activo',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: context.softText),
          ],
        ),
      ),
    );
  }
}
