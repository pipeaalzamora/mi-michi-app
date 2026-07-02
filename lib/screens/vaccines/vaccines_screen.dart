import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../models/vaccine.dart';
import '../../services/vaccines_service.dart';
import '../../services/notification_service.dart';

// Vacunas sugeridas (datos locales — no cambian)
const _suggestedVaccines = [
  {'name': 'Trivalente felina (FVRCP)', 'importance': 'esencial'},
  {'name': 'Leucemia felina (FeLV)', 'importance': 'recomendada'},
  {'name': 'Rabia', 'importance': 'esencial'},
  {'name': 'Desparasitación interna', 'importance': 'esencial'},
  {'name': 'Antiparasitario externo', 'importance': 'recomendada'},
];

class VaccinesScreen extends ConsumerStatefulWidget {
  const VaccinesScreen({super.key});

  @override
  ConsumerState<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends ConsumerState<VaccinesScreen> {
  List<Vaccine> _vaccines = [];
  bool _loading = true;
  String? _error;

  // Datos demo eliminados — usa API real

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) {
      setState(() {
        _vaccines = [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vaccines = await VaccinesService.list(catId);
      if (mounted) {
        setState(() {
          _vaccines = vaccines;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _openForm({Vaccine? editing, String? suggestedName}) async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _VaccineForm(
        catId: catId,
        editing: editing,
        suggestedName: suggestedName,
        onSaved: _fetch,
      ),
    );
  }

  Future<void> _delete(Vaccine v) async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar vacuna'),
        content: const Text('¿Seguro que quieres eliminar este registro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await VaccinesService.delete(catId, v.id);
      _fetch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacunas'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm()),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😿', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('Error al cargar',
                          style: TextStyle(color: context.softText)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: _fetch, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Mis registros
                      const Text('Mis registros',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_vaccines.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.subtleFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.appBorder),
                          ),
                          child: Center(
                            child: Text('Aún no has registrado vacunas.',
                                style: TextStyle(color: context.softText)),
                          ),
                        )
                      else
                        ...(_vaccines.map((v) => _VaccineCard(
                              vaccine: v,
                              onEdit: () => _openForm(editing: v),
                              onDelete: () => _delete(v),
                            ))),
                      const SizedBox(height: 24),

                      // Calendario sugerido
                      const Text('Calendario sugerido',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Referencia general — confirma con tu veterinario.',
                          style:
                              TextStyle(fontSize: 12, color: context.softText)),
                      const SizedBox(height: 8),
                      ...(_suggestedVaccines.map((sv) => _SuggestedCard(
                            name: sv['name']!,
                            importance: sv['importance']!,
                            onRegister: () =>
                                _openForm(suggestedName: sv['name']),
                          ))),
                    ],
                  ),
                ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final Vaccine vaccine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _VaccineCard(
      {required this.vaccine, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final days = vaccine.daysUntilDue;
    Color? badgeColor;
    String? badgeText;
    if (days != null) {
      if (days < 0) {
        badgeColor = AppTheme.error;
        badgeText = 'Vencida';
      } else if (days <= 30) {
        badgeColor = AppTheme.warning;
        badgeText = 'En $days días';
      } else {
        badgeColor = const Color(0xFF059669);
        badgeText = 'En $days días';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(vaccine.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit),
                IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.error),
                    onPressed: onDelete),
              ],
            ),
            Text('Aplicada: ${vaccine.appliedDate}',
                style: TextStyle(fontSize: 12, color: context.softText)),
            if (vaccine.veterinarian != null)
              Text('Vet: ${vaccine.veterinarian}',
                  style: TextStyle(fontSize: 12, color: context.softText)),
            if (badgeText != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor!.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Próxima: $badgeText',
                    style: TextStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  final String name;
  final String importance;
  final VoidCallback onRegister;
  const _SuggestedCard(
      {required this.name, required this.importance, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    final isEssential = importance == 'esencial';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isEssential
                          ? AppTheme.error.withValues(alpha: 0.1)
                          : AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      importance,
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              isEssential ? AppTheme.error : AppTheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRegister,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccineForm extends ConsumerStatefulWidget {
  final String catId;
  final Vaccine? editing;
  final String? suggestedName;
  final VoidCallback onSaved;
  const _VaccineForm(
      {required this.catId,
      this.editing,
      this.suggestedName,
      required this.onSaved});

  @override
  ConsumerState<_VaccineForm> createState() => _VaccineFormState();
}

class _VaccineFormState extends ConsumerState<_VaccineForm> {
  final _nameCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _appliedDate = DateTime.now().toIso8601String().split('T').first;
  String? _nextDueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      final e = widget.editing!;
      _nameCtrl.text = e.name;
      _vetCtrl.text = e.veterinarian ?? '';
      _notesCtrl.text = e.notes ?? '';
      _appliedDate = e.appliedDate;
      _nextDueDate = e.nextDueDate;
    } else if (widget.suggestedName != null) {
      _nameCtrl.text = widget.suggestedName!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _vetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      if (widget.editing == null) {
        await VaccinesService.create(
          catId: widget.catId,
          name: _nameCtrl.text.trim(),
          appliedDate: _appliedDate,
          nextDueDate: _nextDueDate,
          veterinarian:
              _vetCtrl.text.trim().isEmpty ? null : _vetCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      } else {
        await VaccinesService.update(
          catId: widget.catId,
          vacId: widget.editing!.id,
          name: _nameCtrl.text.trim(),
          appliedDate: _appliedDate,
          nextDueDate: _nextDueDate,
          veterinarian:
              _vetCtrl.text.trim().isEmpty ? null : _vetCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      // Programar notificación local si hay próxima dosis
      if (_nextDueDate != null) {
        final due = DateTime.tryParse(_nextDueDate!);
        if (due != null) {
          await NotificationService.scheduleVaccineReminder(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            catName: 'tu gato',
            vaccineName: _nameCtrl.text.trim(),
            dueDate: due,
          );
        }
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.editing == null ? 'Registrar vacuna' : 'Editar vacuna',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Vacuna *')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_appliedDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) {
                      setState(() =>
                          _appliedDate = d.toIso8601String().split('T').first);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration:
                          const InputDecoration(labelText: 'Aplicada el *'),
                      controller: TextEditingController(text: _appliedDate),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2040),
                    );
                    if (d != null) {
                      setState(() =>
                          _nextDueDate = d.toIso8601String().split('T').first);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration:
                          const InputDecoration(labelText: 'Próxima dosis'),
                      controller:
                          TextEditingController(text: _nextDueDate ?? ''),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
              controller: _vetCtrl,
              decoration: const InputDecoration(labelText: 'Veterinario')),
          const SizedBox(height: 10),
          TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 2),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
