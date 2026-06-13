import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../models/external_cat_content.dart';
import '../../services/integrations_service.dart';

const _fallbackTips = [
  CareTipInfo(
    id: 'local-food-water',
    category: 'Alimentación',
    emoji: '🍗',
    title: 'Agua fresca',
    text:
        'Dale agua fresca todos los días. Los gatos son propensos a la deshidratación.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-food-transition',
    category: 'Alimentación',
    emoji: '🍗',
    title: 'Cambio de alimento',
    text:
        'Evita cambiar de alimento de golpe. Hazlo gradualmente en 7-10 días.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-hygiene-litter',
    category: 'Higiene',
    emoji: '🛁',
    title: 'Arenero',
    text:
        'Limpia el arenero al menos una vez al día. Los gatos son muy limpios.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-play-daily',
    category: 'Juego',
    emoji: '🎾',
    title: 'Juego diario',
    text:
        'Juega con tu gato al menos 15 minutos al día para reducir el estrés.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-health-vet',
    category: 'Salud',
    emoji: '❤️',
    title: 'Veterinario',
    text:
        'Lleva a tu gato al veterinario al menos una vez al año aunque esté sano.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-behavior-purr',
    category: 'Comportamiento',
    emoji: '🧠',
    title: 'Ronroneo',
    text:
        'El ronroneo no siempre significa felicidad; también puede indicar dolor o estrés.',
    source: 'Local',
  ),
  CareTipInfo(
    id: 'local-home-plants',
    category: 'Hogar',
    emoji: '🏠',
    title: 'Plantas',
    text:
        'Asegúrate de que no haya plantas tóxicas en casa, como lirios, pothos o aloe vera.',
    source: 'Local',
  ),
];

const _categories = [
  'Todos',
  'Alimentación',
  'Higiene',
  'Juego',
  'Salud',
  'Comportamiento',
  'Hogar',
  'Razas',
];

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _selected = 'Todos';
  List<CareTipInfo> _tips = _fallbackTips;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tips = await IntegrationsService.careTips(
        query: _searchCtrl.text,
        category: _selected,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _tips = tips.isEmpty ? [] : tips;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tips = _filteredFallback();
        _error = 'Mostrando consejos locales. No se pudo conectar a la API.';
        _loading = false;
      });
    }
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadTips);
  }

  List<CareTipInfo> _filteredFallback() {
    final query = _normalize(_searchCtrl.text);
    return _fallbackTips.where((tip) {
      final categoryMatches = _selected == 'Todos' || tip.category == _selected;
      final textMatches = query.isEmpty ||
          _normalize('${tip.category} ${tip.title} ${tip.text}')
              .contains(query);
      return categoryMatches && textMatches;
    }).toList();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[áàäâã]'), 'a')
        .replaceAll(RegExp('[éèëê]'), 'e')
        .replaceAll(RegExp('[íìïî]'), 'i')
        .replaceAll(RegExp('[óòöôõ]'), 'o')
        .replaceAll(RegExp('[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consejos')),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadTips,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar tips, razas o cuidados...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _scheduleSearch,
              onSubmitted: (_) => _loadTips(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final category = _categories[i];
                  final active = category == _selected;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selected = category);
                      _loadTips();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : context.subtleFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? AppTheme.primary : context.appBorder,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: active ? Colors.white : context.softText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              _InlineNotice(message: _error!),
            ],
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_tips.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Text(
                    'No hay consejos con ese filtro',
                    style: TextStyle(color: context.softText),
                  ),
                ),
              )
            else
              ..._tips.map((tip) => _TipCard(tip: tip)),
          ],
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final String message;

  const _InlineNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.softTint(const Color(0xFFFEF3C7)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: context.softText),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final CareTipInfo tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: context.softShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Chip(label: tip.category),
                    if (tip.source.isNotEmpty) _Chip(label: tip.source),
                  ],
                ),
                const SizedBox(height: 8),
                if (tip.title.isNotEmpty) ...[
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(tip.text, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.chipFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
