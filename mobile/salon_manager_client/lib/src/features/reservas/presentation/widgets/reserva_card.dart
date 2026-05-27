import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/reserva.dart';

class ReservaCard extends StatelessWidget {
  const ReservaCard({required this.reserva, super.key});

  final Reserva reserva;

  @override
  Widget build(BuildContext context) {
    final color = switch (reserva.status) {
      'CONFIRMADA' => AppTheme.teal,
      'RECUSADA' => AppTheme.coral,
      'CONCLUIDA' => Colors.blueGrey,
      _ => AppTheme.amber,
    };

    final icon = switch (reserva.status) {
      'CONFIRMADA' => Icons.verified_rounded,
      'RECUSADA' => Icons.block_rounded,
      'CONCLUIDA' => Icons.done_all_rounded,
      _ => Icons.hourglass_top_rounded,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.salaoNome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatters.compact(reserva.dataReserva),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusPill(label: reserva.status, color: color),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(
                  icon: Icons.person_rounded,
                  label: reserva.clienteNome,
                  color: AppTheme.teal,
                ),
                StatusPill(
                  icon: Icons.tag_rounded,
                  label: '#${reserva.id}',
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
