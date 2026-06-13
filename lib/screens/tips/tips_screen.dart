import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';

const _tips = [
  {
    'category': 'Alimentación',
    'emoji': '🍗',
    'text':
        'Dale agua fresca todos los días. Los gatos son propensos a la deshidratación.'
  },
  {
    'category': 'Alimentación',
    'emoji': '🍗',
    'text':
        'Divide la comida en 2-3 porciones al día en lugar de dejar el plato lleno.'
  },
  {
    'category': 'Alimentación',
    'emoji': '🍗',
    'text':
        'Evita cambiar de alimento de golpe. Hazlo gradualmente en 7-10 días.'
  },
  {
    'category': 'Higiene',
    'emoji': '🛁',
    'text':
        'Limpia el arenero al menos una vez al día. Los gatos son muy limpios.'
  },
  {
    'category': 'Higiene',
    'emoji': '🛁',
    'text': 'Cepilla a tu gato regularmente para reducir las bolas de pelo.'
  },
  {
    'category': 'Higiene',
    'emoji': '🛁',
    'text': 'Revisa y corta las uñas cada 2-3 semanas.'
  },
  {
    'category': 'Juego',
    'emoji': '🎾',
    'text':
        'Juega con tu gato al menos 15 minutos al día para reducir el estrés.'
  },
  {
    'category': 'Juego',
    'emoji': '🎾',
    'text':
        'Los juguetes que imitan presas (ratones, plumas) son los favoritos.'
  },
  {
    'category': 'Salud',
    'emoji': '❤️',
    'text':
        'Lleva a tu gato al veterinario al menos una vez al año aunque esté sano.'
  },
  {
    'category': 'Salud',
    'emoji': '❤️',
    'text':
        'La esterilización reduce el riesgo de enfermedades y comportamientos no deseados.'
  },
  {
    'category': 'Comportamiento',
    'emoji': '🧠',
    'text':
        'Si tu gato esconde, puede estar estresado o enfermo. Observa otros síntomas.'
  },
  {
    'category': 'Comportamiento',
    'emoji': '🧠',
    'text':
        'El ronroneo no siempre significa felicidad; también puede indicar dolor o estrés.'
  },
  {
    'category': 'Hogar',
    'emoji': '🏠',
    'text':
        'Asegúrate de que no haya plantas tóxicas en casa (lirios, pothos, aloe vera).'
  },
  {
    'category': 'Hogar',
    'emoji': '🏠',
    'text': 'Un rascador alto y estable evita que arruine tus muebles.'
  },
];

const _categories = [
  'Todos',
  'Alimentación',
  'Higiene',
  'Juego',
  'Salud',
  'Comportamiento',
  'Hogar'
];

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _selected = 'Todos';

  @override
  Widget build(BuildContext context) {
    final filtered = _tips
        .where((t) => _selected == 'Todos' || t['category'] == _selected)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Consejos')),
      body: Column(
        children: [
          // Filtros
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final active = cat == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = cat),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : context.subtleFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? AppTheme.primary : context.appBorder,
                      ),
                    ),
                    child: Text(
                      cat,
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final tip = filtered[i];
                return Container(
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
                      Text(tip['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tip['category']!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(tip['text']!,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
