import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/cat_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'screens/adoptions/adoptions_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/breeds/breeds_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cats/cats_list_screen.dart';
import 'screens/cats/cat_form_screen.dart';
import 'screens/cats/cat_profile_screen.dart';
import 'screens/health/health_screen.dart';
import 'screens/vaccines/vaccines_screen.dart';
import 'screens/foods/foods_screen.dart';
import 'screens/tips/tips_screen.dart';
import 'screens/settings/settings_screen.dart';

GoRouter _createRouter({
  required bool showOnboarding,
  required WidgetRef ref,
}) =>
    GoRouter(
      initialLocation: showOnboarding ? '/onboarding' : '/',
      redirect: (_, state) {
        final auth = ref.read(authProvider);
        final location = state.matchedLocation;

        if (location == '/onboarding') {
          return null;
        }
        if (auth.status == AuthStatus.loading) {
          return location == '/login' ? null : '/login';
        }
        if (auth.status == AuthStatus.unauthenticated && location != '/login') {
          return '/login';
        }
        if (auth.status == AuthStatus.authenticated && location == '/login') {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        ShellRoute(
          builder: (context, state, child) => _MainShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/cats', builder: (_, __) => const CatsListScreen()),
            GoRoute(
                path: '/cats/new', builder: (_, __) => const CatFormScreen()),
            GoRoute(
              path: '/cats/:id',
              builder: (_, state) =>
                  CatProfileScreen(catId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/cats/:id/edit',
              builder: (_, state) =>
                  CatFormScreen(catId: state.pathParameters['id']),
            ),
            GoRoute(path: '/health', builder: (_, __) => const HealthScreen()),
            GoRoute(
                path: '/vaccines', builder: (_, __) => const VaccinesScreen()),
            GoRoute(path: '/foods', builder: (_, __) => const FoodsScreen()),
            GoRoute(path: '/tips', builder: (_, __) => const TipsScreen()),
            GoRoute(path: '/breeds', builder: (_, __) => const BreedsScreen()),
            GoRoute(
                path: '/adoptions',
                builder: (_, __) => const AdoptionsScreen()),
            GoRoute(
                path: '/settings', builder: (_, __) => const SettingsScreen()),
          ],
        ),
      ],
    );

class MiMichiApp extends ConsumerStatefulWidget {
  final bool showOnboarding;
  const MiMichiApp({super.key, this.showOnboarding = false});

  @override
  ConsumerState<MiMichiApp> createState() => _MiMichiAppState();
}

class _MiMichiAppState extends ConsumerState<MiMichiApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter(
      showOnboarding: widget.showOnboarding,
      ref: ref,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, __) => _router.refresh());
    final auth = ref.watch(authProvider);
    final catTheme = auth.status == AuthStatus.authenticated
        ? ref.watch(catThemeProvider)
        : CatTheme.desconocido;
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mi Michi',
      theme: catTheme.toThemeData(dark: false),
      darkTheme: catTheme.toThemeData(dark: true),
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Bottom navigation shell con transición animada de tema
class _MainShell extends ConsumerWidget {
  final Widget child;
  const _MainShell({required this.child});

  static const _tabs = [
    {
      'path': '/',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Inicio'
    },
    {
      'path': '/cats',
      'icon': Icons.pets_outlined,
      'activeIcon': Icons.pets,
      'label': 'Gatos'
    },
    {
      'path': '/health',
      'icon': Icons.favorite_outline,
      'activeIcon': Icons.favorite,
      'label': 'Salud'
    },
    {
      'path': '/vaccines',
      'icon': Icons.vaccines_outlined,
      'activeIcon': Icons.vaccines,
      'label': 'Vacunas'
    },
    {
      'path': '/tips',
      'icon': Icons.lightbulb_outline,
      'activeIcon': Icons.lightbulb,
      'label': 'Tips'
    },
  ];

  int _currentIndex(String location) {
    if (location.startsWith('/cats')) return 1;
    if (location.startsWith('/health')) return 2;
    if (location.startsWith('/vaccines')) return 3;
    if (location.startsWith('/tips') ||
        location.startsWith('/foods') ||
        location.startsWith('/breeds') ||
        location.startsWith('/adoptions')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: AnimatedTheme(
        data: Theme.of(context),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i]['path'] as String),
        selectedItemColor: primary,
        items: _tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab['icon'] as IconData),
                  activeIcon: Icon(tab['activeIcon'] as IconData),
                  label: tab['label'] as String,
                ))
            .toList(),
      ),
    );
  }
}
