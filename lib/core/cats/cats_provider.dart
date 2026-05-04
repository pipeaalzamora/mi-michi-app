import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/cat.dart';
import '../../services/cats_service.dart';

const _activeCatKey = 'mi_michi_active_cat';
const _storage = FlutterSecureStorage();

class CatsState {
  final List<Cat> cats;
  final String? activeCatId;
  final bool loading;
  final String? error;

  const CatsState({
    this.cats = const [],
    this.activeCatId,
    this.loading = false, // false por defecto — no carga hasta que haya auth
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
  CatsNotifier() : super(const CatsState());

  // Llamado explícitamente desde el home cuando el usuario ya está autenticado
  Future<void> init() async {
    final savedId = await _storage.read(key: _activeCatKey);
    await refresh(initialActiveCatId: savedId);
  }

  Future<void> refresh({String? initialActiveCatId}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cats = await CatsService.list();
      String? activeId = initialActiveCatId ?? state.activeCatId;
      if (activeId != null && !cats.any((c) => c.id == activeId)) {
        activeId = cats.isNotEmpty ? cats.first.id : null;
      }
      state = CatsState(cats: cats, activeCatId: activeId, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
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
