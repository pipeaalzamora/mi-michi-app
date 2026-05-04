import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

const _foodGuide = [
  {
    'key': 'safe',
    'title': 'Alimentos seguros',
    'emoji': '✅',
    'color': 0xFFD1FAE5,
    'items': [
      {'name': 'Pollo cocido sin sal', 'notes': 'Sin huesos, sin condimentos.'},
      {'name': 'Pavo cocido', 'notes': 'Sin sal, sin piel grasa.'},
      {'name': 'Pescado cocido', 'notes': 'Salmón, atún o merluza. Sin espinas.'},
      {'name': 'Huevo cocido', 'notes': '1-2 veces por semana.'},
      {'name': 'Calabaza cocida', 'notes': 'Ayuda con el tránsito intestinal.'},
      {'name': 'Arroz cocido', 'notes': 'Útil si tiene malestar digestivo.'},
    ],
  },
  {
    'key': 'moderate',
    'title': 'Con moderación',
    'emoji': '⚠️',
    'color': 0xFFFEF3C7,
    'items': [
      {'name': 'Queso', 'notes': 'Muchos gatos son intolerantes a la lactosa.'},
      {'name': 'Yogur natural', 'notes': 'Sin azúcar. Una cucharadita ocasional.'},
      {'name': 'Atún en lata', 'notes': 'Solo al natural. Como premio puntual.'},
    ],
  },
  {
    'key': 'avoid',
    'title': 'Evitar',
    'emoji': '🚫',
    'color': 0xFFFFE4E6,
    'items': [
      {'name': 'Sal y alimentos salados', 'notes': 'Daña los riñones.'},
      {'name': 'Azúcar y dulces', 'notes': 'Causa obesidad y problemas dentales.'},
      {'name': 'Comida para perros', 'notes': 'No cubre las necesidades del gato.'},
      {'name': 'Leche de vaca', 'notes': 'La mayoría son intolerantes.'},
    ],
  },
  {
    'key': 'toxic',
    'title': 'Tóxicos ⚠️',
    'emoji': '☠️',
    'color': 0xFFFEE2E2,
    'items': [
      {'name': 'Chocolate', 'notes': 'Muy tóxico. Puede ser mortal.'},
      {'name': 'Cebolla y ajo', 'notes': 'Destruyen los glóbulos rojos.'},
      {'name': 'Uvas y pasas', 'notes': 'Causan insuficiencia renal.'},
      {'name': 'Cafeína', 'notes': 'Café, té, bebidas energéticas.'},
      {'name': 'Alcohol', 'notes': 'Extremadamente peligroso.'},
      {'name': 'Xilitol', 'notes': 'Edulcorante artificial. Fatal.'},
      {'name': 'Aguacate', 'notes': 'Contiene persina, tóxica para gatos.'},
    ],
  },
];

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía de alimentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _foodGuide.map((category) {
                final items = (category['items'] as List)
                    .where((item) => _search.isEmpty ||
                        (item as Map)['name']!
                            .toLowerCase()
                            .contains(_search.toLowerCase()))
                    .toList();
                if (items.isEmpty) return const SizedBox();
                return _FoodCategory(
                  title: category['title'] as String,
                  emoji: category['emoji'] as String,
                  color: Color(category['color'] as int),
                  items: items.cast<Map<String, String>>(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCategory extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final List<Map<String, String>> items;

  const _FoodCategory({
    required this.title,
    required this.emoji,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name']!,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(item['notes']!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
