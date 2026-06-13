import 'package:flutter/material.dart';
import '../core/theme/theme_extensions.dart';
import '../models/health_log.dart';

class WeightWidget extends StatelessWidget {
  final List<HealthLog> logs;

  const WeightWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final weightLogs = logs
        .where((l) => l.logType == 'peso' && l.numericValue != null)
        .toList()
      ..sort((a, b) => b.logDate.compareTo(a.logDate));

    if (weightLogs.isEmpty) return const SizedBox();

    final latest = weightLogs.first;
    final previous = weightLogs.length > 1 ? weightLogs[1] : null;
    final diff =
        previous != null ? latest.numericValue! - previous.numericValue! : null;

    final isUp = diff != null && diff > 0;
    final isDown = diff != null && diff < 0;
    final trendColor = isUp
        ? const Color(0xFFEF4444)
        : isDown
            ? const Color(0xFF10B981)
            : const Color(0xFF94A3B8);
    final trendIcon = isUp
        ? Icons.trending_up
        : isDown
            ? Icons.trending_down
            : Icons.trending_flat;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        children: [
          const Text('⚖️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Peso actual',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                Text(
                  '${latest.numericValue} kg',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          if (diff != null) ...[
            Icon(trendIcon, color: trendColor, size: 20),
            const SizedBox(width: 4),
            Text(
              '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
              style: TextStyle(
                  color: trendColor, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
