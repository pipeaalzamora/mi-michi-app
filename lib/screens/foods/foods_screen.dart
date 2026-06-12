import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/food_product.dart';
import '../../services/integrations_service.dart';

const _foodGuide = [
  {
    'key': 'safe',
    'title': 'Alimentos seguros',
    'emoji': '✅',
    'color': 0xFFD1FAE5,
    'items': [
      {'name': 'Pollo cocido sin sal', 'notes': 'Sin huesos, sin condimentos.'},
      {'name': 'Pavo cocido', 'notes': 'Sin sal, sin piel grasa.'},
      {
        'name': 'Pescado cocido',
        'notes': 'Salmón, atún o merluza. Sin espinas.'
      },
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
      {
        'name': 'Yogur natural',
        'notes': 'Sin azúcar. Una cucharadita ocasional.'
      },
      {
        'name': 'Atún en lata',
        'notes': 'Solo al natural. Como premio puntual.'
      },
    ],
  },
  {
    'key': 'avoid',
    'title': 'Evitar',
    'emoji': '🚫',
    'color': 0xFFFFE4E6,
    'items': [
      {'name': 'Sal y alimentos salados', 'notes': 'Daña los riñones.'},
      {
        'name': 'Azúcar y dulces',
        'notes': 'Causa obesidad y problemas dentales.'
      },
      {
        'name': 'Comida para perros',
        'notes': 'No cubre las necesidades del gato.'
      },
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
  final _barcodeCtrl = TextEditingController();
  final _onlineSearchCtrl = TextEditingController();
  FoodProduct? _barcodeProduct;
  List<FoodProduct> _onlineResults = [];
  bool _loadingBarcode = false;
  bool _loadingSearch = false;
  String? _onlineError;

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _onlineSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeCtrl.text.trim();
    if (barcode.isEmpty) return;
    setState(() {
      _loadingBarcode = true;
      _onlineError = null;
      _barcodeProduct = null;
    });
    try {
      final product = await IntegrationsService.foodProduct(barcode);
      if (mounted) setState(() => _barcodeProduct = product);
    } catch (e) {
      if (mounted) setState(() => _onlineError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingBarcode = false);
    }
  }

  Future<void> _searchOnline() async {
    final query = _onlineSearchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loadingSearch = true;
      _onlineError = null;
      _onlineResults = [];
    });
    try {
      final results = await IntegrationsService.searchFoodProducts(query);
      if (mounted) setState(() => _onlineResults = results);
    } catch (e) {
      if (mounted) setState(() => _onlineError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingSearch = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía de alimentos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _OnlineFoodLookup(
            barcodeCtrl: _barcodeCtrl,
            searchCtrl: _onlineSearchCtrl,
            loadingBarcode: _loadingBarcode,
            loadingSearch: _loadingSearch,
            error: _onlineError,
            barcodeProduct: _barcodeProduct,
            results: _onlineResults,
            onLookupBarcode: _lookupBarcode,
            onSearch: _searchOnline,
          ),
          const SizedBox(height: 18),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar en la guía local...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primary),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 16),
          ..._foodGuide.map((category) {
            final items = (category['items'] as List)
                .where((item) =>
                    _search.isEmpty ||
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
          }),
        ],
      ),
    );
  }
}

class _OnlineFoodLookup extends StatelessWidget {
  final TextEditingController barcodeCtrl;
  final TextEditingController searchCtrl;
  final bool loadingBarcode;
  final bool loadingSearch;
  final String? error;
  final FoodProduct? barcodeProduct;
  final List<FoodProduct> results;
  final VoidCallback onLookupBarcode;
  final VoidCallback onSearch;

  const _OnlineFoodLookup({
    required this.barcodeCtrl,
    required this.searchCtrl,
    required this.loadingBarcode,
    required this.loadingSearch,
    required this.error,
    required this.barcodeProduct,
    required this.results,
    required this.onLookupBarcode,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alimento comercial',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: barcodeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Código de barras',
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                  ),
                  onSubmitted: (_) => onLookupBarcode(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: loadingBarcode ? null : onLookupBarcode,
                icon: loadingBarcode
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Buscar marca o producto',
                    prefixIcon: Icon(Icons.manage_search_outlined),
                  ),
                  onSubmitted: (_) => onSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: loadingSearch ? null : onSearch,
                icon: loadingSearch
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: AppTheme.error)),
          ],
          if (barcodeProduct != null) ...[
            const SizedBox(height: 12),
            _FoodProductCard(product: barcodeProduct!),
          ],
          if (results.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...results.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FoodProductCard(product: product),
                )),
          ],
        ],
      ),
    );
  }
}

class _FoodProductCard extends StatelessWidget {
  final FoodProduct product;

  const _FoodProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final protein = product.nutrient('proteins_100g');
    final fat = product.nutrient('fat_100g');
    final carbs = product.nutrient('carbohydrates_100g');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.imageUrl.isEmpty
                ? Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(Icons.inventory_2_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.inventory_2_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                if (product.brands.isNotEmpty)
                  Text(product.brands,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (protein.isNotEmpty)
                      _MetricChip(label: 'Prot $protein%'),
                    if (fat.isNotEmpty) _MetricChip(label: 'Grasa $fat%'),
                    if (carbs.isNotEmpty) _MetricChip(label: 'Carb $carbs%'),
                    if (product.novaGroup.isNotEmpty)
                      _MetricChip(label: 'NOVA ${product.novaGroup}'),
                  ],
                ),
                if (product.ingredientsText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.ingredientsText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
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

class _MetricChip extends StatelessWidget {
  final String label;

  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(item['notes']!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700])),
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
