import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/cat_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/cat.dart';
import '../../models/health_log.dart';
import '../../data/life_stages.dart';
import '../../widgets/weight_widget.dart';
import '../../widgets/cat_3d_viewer.dart';
import '../../services/health_service.dart';

const _tips = [
  'Los gatos duermen entre 12 y 16 horas al día. ¡Es normal!',
  'Cambia el agua de tu michi todos los días, prefieren agua fresca.',
  'Cepillarlo a menudo reduce las bolas de pelo y refuerza su vínculo contigo.',
  'Un rascador alto evita que arruine tus muebles.',
  'Jugar 10-15 minutos al día reduce su estrés y peso.',
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<HealthLog> _weightLogs = [];

  @override
  void initState() {
    super.initState();
    // Cargar logs de peso cuando el gato activo esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeightLogs());
  }

  Future<void> _loadWeightLogs() async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) return;
    try {
      final logs = await HealthService.list(catId);
      if (mounted) {
        setState(() {
          _weightLogs = logs.where((l) => l.logType == 'peso').toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final catsState = ref.watch(catsProvider);
    final catTheme = ref.watch(catThemeProvider);
    final activeCat = catsState.activeCat;
    final tip = _tips[DateTime.now().day % _tips.length];

    // Recargar peso cuando cambia el gato activo
    ref.listen(catsProvider, (prev, next) {
      if (prev?.activeCatId != next.activeCatId) {
        _loadWeightLogs();
      }
    });

    if (catsState.loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: catTheme.primary)));
    }

    // Sin gatos — pantalla de bienvenida
    if (catsState.cats.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐱', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text('¡Bienvenidx a Mi Michi!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text('Para empezar, cuéntanos sobre tu primer gatito.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => context.push('/cats/new'),
                  child: const Text('Añadir mi gato'),
                ),
                TextButton(
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  child: Text('Cerrar sesión', style: TextStyle(color: Colors.grey[500])),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: catTheme.primary,
          onRefresh: () => ref.read(catsProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola 👋',
                            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                        _CatSelector(
                          cats: catsState.cats,
                          activeCatId: catsState.activeCatId,
                          onChanged: (id) =>
                              ref.read(catsProvider.notifier).setActiveCat(id),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero del gato activo
              if (activeCat != null) _CatHeroCard(cat: activeCat, catTheme: catTheme),
              const SizedBox(height: 16),

              // Widget de peso
              WeightWidget(logs: _weightLogs),
              const SizedBox(height: 16),

              // Etapa de vida
              if (activeCat?.birthDate != null)
                _LifeStageCard(birthDate: activeCat!.birthDate!),
              const SizedBox(height: 16),

              // Tip del día
              _TipCard(tip: tip),
              const SizedBox(height: 16),

              // Accesos rápidos
              Row(
                children: [
                  _QuickAction(
                    label: 'Vacunas',
                    emoji: '💉',
                    color: const Color(0xFFEDE9FE),
                    onTap: () => context.push('/vaccines'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'Alimentos',
                    emoji: '🍗',
                    color: const Color(0xFFD1FAE5),
                    onTap: () => context.push('/foods'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    label: 'Salud',
                    emoji: '❤️',
                    color: const Color(0xFFFFE4E6),
                    onTap: () => context.push('/health'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatSelector extends StatelessWidget {
  final List<Cat> cats;
  final String? activeCatId;
  final ValueChanged<String> onChanged;

  const _CatSelector({
    required this.cats,
    required this.activeCatId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (cats.length == 1) {
      return Text(cats.first.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800));
    }
    return DropdownButton<String>(
      value: activeCatId ?? cats.first.id,
      underline: const SizedBox(),
      style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B)),
      items: cats
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: (id) { if (id != null) onChanged(id); },
    );
  }
}

class _CatHeroCard extends StatelessWidget {
  final Cat cat;
  final CatTheme catTheme;
  const _CatHeroCard({required this.cat, required this.catTheme});

  @override
  Widget build(BuildContext context) {
    final stage = LifeStages.calculate(cat.birthDate);
    final age = LifeStages.formatAge(cat.birthDate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: catTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: catTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modelo 3D compacto
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Cat3DViewerCompact(
              color: cat.color,
              breed: cat.breed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name,
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(age,
                              style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          if (stage != null)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${stage.emoji} ${stage.label}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/cats/${cat.id}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Ver perfil completo'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeStageCard extends StatelessWidget {
  final String birthDate;
  const _LifeStageCard({required this.birthDate});

  @override
  Widget build(BuildContext context) {
    final stage = LifeStages.calculate(birthDate);
    if (stage == null) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Etapa: ${stage.label}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(stage.ageRange,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(stage.description,
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF059669)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tip del día',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46))),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF065F46))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
