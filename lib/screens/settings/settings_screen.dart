import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _editingName = false;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await ref
        .read(authProvider.notifier)
        .updateDisplayName(_nameCtrl.text.trim());
    setState(() => _editingName = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre actualizado ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Cuenta ────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu cuenta',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primary.withValues(alpha: 0.15),
                        backgroundImage: (user?.picture.isNotEmpty == true)
                            ? NetworkImage(user!.picture)
                            : null,
                        child: (user?.picture.isEmpty != false)
                            ? Icon(Icons.person, color: primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(user?.email ?? '',
                            style: TextStyle(
                                color: context.softText, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Nombre visible',
                      style: TextStyle(fontSize: 13, color: context.softText)),
                  const SizedBox(height: 6),
                  if (_editingName)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                                hintText: 'Tu nombre', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                            icon: Icon(Icons.check, color: primary),
                            onPressed: _saveName),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _editingName = false)),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName
                                : 'Sin nombre',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => setState(() => _editingName = true),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Apariencia ────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Apariencia',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ThemeOption(
                        icon: Icons.wb_sunny_outlined,
                        label: 'Claro',
                        selected: themeMode == ThemeMode.light,
                        primary: primary,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 10),
                      _ThemeOption(
                        icon: Icons.nightlight_outlined,
                        label: 'Oscuro',
                        selected: themeMode == ThemeMode.dark,
                        primary: primary,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.dark),
                      ),
                      const SizedBox(width: 10),
                      _ThemeOption(
                        icon: Icons.phone_android_outlined,
                        label: 'Sistema',
                        selected: themeMode == ThemeMode.system,
                        primary: primary,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.system),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    themeMode == ThemeMode.system
                        ? 'Se ajusta automáticamente a tu dispositivo.'
                        : themeMode == ThemeMode.dark
                            ? 'Modo oscuro activado.'
                            : 'Modo claro activado.',
                    style: TextStyle(fontSize: 12, color: context.softText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Cerrar sesión ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x66EF4444)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? primary.withValues(alpha: 0.12) : context.subtleFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? primary : context.appBorder,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? primary : context.softText, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? primary : context.softText)),
            ],
          ),
        ),
      ),
    );
  }
}
