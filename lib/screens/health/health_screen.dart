import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/cats/cats_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../models/health_log.dart';
import '../../services/health_service.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  List<HealthLog> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // Recarga cuando cambia el gato activo
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetch();
  }

  Future<void> _fetch() async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) {
      setState(() {
        _logs = [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final logs = await HealthService.list(catId);
      if (mounted) {
        setState(() {
          _logs = logs;
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

  void _openForm({HealthLog? editing}) async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LogForm(catId: catId, editing: editing, onSaved: _fetch),
    );
  }

  Future<void> _delete(HealthLog log) async {
    final catId = ref.read(catsProvider).activeCat?.id;
    if (catId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
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
      await HealthService.delete(catId, log.id);
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
    final primary = Theme.of(context).colorScheme.primary;
    final weightPoints = _logs
        .where((l) => l.logType == 'peso' && l.numericValue != null)
        .toList()
        .reversed
        .toList();

    final lastWeight = weightPoints.isNotEmpty ? weightPoints.last : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario de salud'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm()),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
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
                  color: primary,
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Resumen
                      Row(
                        children: [
                          _StatCard(
                            label: 'Último peso',
                            value: lastWeight != null
                                ? '${lastWeight.numericValue} kg'
                                : '—',
                            color: const Color(0xFFD1FAE5),
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Registros',
                            value: '${_logs.length}',
                            color: const Color(0xFFEDE9FE),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gráfico de peso
                      if (weightPoints.length >= 2) ...[
                        const Text('Evolución de peso',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: weightPoints
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(),
                                          e.value.numericValue!))
                                      .toList(),
                                  isCurved: true,
                                  color: primary,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: primary.withValues(alpha: 0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Historial
                      const Text('Historial',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_logs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                const Text('📋',
                                    style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text('Aún no hay registros.',
                                    style: TextStyle(color: context.softText)),
                                const SizedBox(height: 4),
                                Text('Toca + para añadir el primero.',
                                    style: TextStyle(
                                        color: context.softText, fontSize: 12)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...(_logs.map((log) => _LogCard(
                              log: log,
                              onEdit: () => _openForm(editing: log),
                              onDelete: () => _delete(log),
                            ))),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.softTint(color),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appBorder.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: context.softText)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final HealthLog log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _LogCard(
      {required this.log, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final meta =
        logMetaMap[log.logType] ?? const LogMeta(label: 'Otro', emoji: '📝');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Text(meta.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(log.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${meta.label} · ${log.logDate}',
            style: TextStyle(fontSize: 12, color: context.softText)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.error),
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _LogForm extends ConsumerStatefulWidget {
  final String catId;
  final HealthLog? editing;
  final VoidCallback onSaved;
  const _LogForm({required this.catId, this.editing, required this.onSaved});

  @override
  ConsumerState<_LogForm> createState() => _LogFormState();
}

class _LogFormState extends ConsumerState<_LogForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _numCtrl = TextEditingController();
  String _logType = 'peso';
  String _logDate = DateTime.now().toIso8601String().split('T').first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      final e = widget.editing!;
      _logType = e.logType;
      _logDate = e.logDate;
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description ?? '';
      _numCtrl.text = e.numericValue?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final title = _titleCtrl.text.trim().isEmpty
          ? (_logType == 'peso' && _numCtrl.text.isNotEmpty
              ? '${_numCtrl.text} kg'
              : logMetaMap[_logType]!.label)
          : _titleCtrl.text.trim();

      if (widget.editing == null) {
        await HealthService.create(
          catId: widget.catId,
          logType: _logType,
          logDate: _logDate,
          title: title,
          numericValue: double.tryParse(_numCtrl.text),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
      } else {
        await HealthService.update(
          catId: widget.catId,
          logId: widget.editing!.id,
          logType: _logType,
          logDate: _logDate,
          title: title,
          numericValue: double.tryParse(_numCtrl.text),
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
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
          Text(widget.editing == null ? 'Nuevo registro' : 'Editar registro',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _logType,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: logMetaMap.entries
                .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value.emoji} ${e.value.label}')))
                .toList(),
            onChanged: (v) => setState(() => _logType = v!),
          ),
          const SizedBox(height: 10),
          if (_logType == 'peso')
            TextField(
              controller: _numCtrl,
              decoration: const InputDecoration(
                  labelText: 'Peso (kg)', suffixText: 'kg'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            )
          else
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título *'),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Notas'),
            maxLines: 2,
          ),
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
