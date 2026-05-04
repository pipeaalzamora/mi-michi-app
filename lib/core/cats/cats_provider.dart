import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/cat.dart';

const _activeCatKey = 'mi_michi_active_cat';
const _storage = FlutterSecureStorage();

// Gatos demo
final _demoCats = [
  Cat(
    id: 'cat-1',
    userId: 'demo-user',
    name: 'Mochi',
    birthDate: '2022-03-15',
    breed: 'Mestizo',
    sex: 'hembra',
    color: 'Naranja y blanco',
    weightKg: 4.2,
    photoUrl: null,
    notes: 'Le encanta dormir en el sofá.',
    createdAt: DateTime(2022, 3, 15),
    updatedAt: DateTime.now(),
  ),
  Cat(
    id: 'cat-2',
    userId: 'demo-user',
    name: 'Simba',
    birthDate: '2020-07-01',
    breed: 'Siamés',
    sex: 'macho',
    color: 'Crema con puntas oscuras',
    weightKg: 5.8,
    photoUrl: null,
    notes: 'Muy vocal cuando tiene hambre.',
    createdAt: DateTime(2020, 7, 1),
    updatedAt: DateTime.now(),
  ),
];

class CatsState {
  final List<Cat> cats;
  final String? activeCatId;
  final bool loading;
  final String? error;

  const CatsState({
    this.cats = const [],
    this.activeCatId,
    this.loading = false,
    this.error,
  });

  Cat? get activeCat {
    if (activeCatId == null) return cats.isNotEmpty ? cats.first : null;
    try {
      return cats.firstWhere((c) => c.id == activeCatId);
    } catch (_) {
      return cats.isNotEmpty ? cats.first : null;
    }
  }

  CatsState copyWith({
    List<Cat>? cats,
    String? activeCatId,
    bool? loading,
    String? error,
  }) =>
      CatsState(
        cats: cats ?? this.cats,
        activeCatId: activeCatId ?? this.activeCatId,
        loading: loading ?? this.loading,
        error: error,
      );
}

class CatsNotifier extends StateNotifier<CatsState> {
  CatsNotifier() : super(const CatsState()) {
    _init();
  }

  Future<void> _init() async {
    final savedId = await _storage.read(key: _activeCatKey);
    state = CatsState(
      cats: _demoCats,
      activeCatId: savedId ?? _demoCats.first.id,
      loading: false,
    );
  }

  Future<void> init() async => _init();

  Future<void> refresh({String? initialActiveCatId}) async {
    state = CatsState(
      cats: _demoCats,
      activeCatId: initialActiveCatId ?? state.activeCatId ?? _demoCats.first.id,
      loading: false,
    );
  }

  Future<void> setActiveCat(String id) async {
    await _storage.write(key: _activeCatKey, value: id);
    state = state.copyWith(activeCatId: id);
  }

  void clear() {
    state = const CatsState();
  }
}

final catsProvider = StateNotifierProvider<CatsNotifier, CatsState>(
  (_) => CatsNotifier(),
);
