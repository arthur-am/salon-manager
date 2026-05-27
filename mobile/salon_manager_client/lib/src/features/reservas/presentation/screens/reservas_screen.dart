import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../controllers/reservas_feed_controller.dart';
import '../widgets/event_log_tile.dart';
import '../widgets/reserva_card.dart';

class ReservasScreen extends ConsumerWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reservasFeedControllerProvider);
    final controller = ref.read(reservasFeedControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _SyncPanel(lastSync: state.lastSync),
            const SizedBox(height: 18),
            Text(
              'Minhas reservas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            AsyncStateView(
              value: state.reservas,
              onRetry: controller.refresh,
              loadingLabel: 'Sincronizando reservas',
              data: (reservas) {
                if (reservas.isEmpty) {
                  return const _EmptyReservations();
                }
                return Column(
                  children: [
                    for (final reserva in reservas.take(8))
                      ReservaCard(reserva: reserva),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Event log assincrono',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const StatusPill(
                  icon: Icons.queue_rounded,
                  label: 'RabbitMQ',
                  color: AppTheme.coral,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AsyncStateView(
              value: state.events,
              onRetry: controller.refresh,
              loadingLabel: 'Lendo event_log',
              data: (events) {
                if (events.isEmpty) {
                  return const _EmptyEvents();
                }
                return Column(
                  children: [
                    for (final event in events.take(6)) EventLogTile(event: event),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncPanel extends StatelessWidget {
  const _SyncPanel({required this.lastSync});

  final DateTime? lastSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sync_rounded, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado atualizado em segundo plano',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  lastSync == null
                      ? 'Aguardando primeira sincronizacao'
                      : 'Ultimo sync: ${DateFormatters.compact(lastSync!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    return const _EmptyPanel(
      icon: Icons.event_busy_rounded,
      title: 'Nenhuma reserva ainda',
      subtitle: 'Escolha um salao e envie a primeira solicitacao.',
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    return const _EmptyPanel(
      icon: Icons.inbox_rounded,
      title: 'Sem eventos processados',
      subtitle: 'Crie uma reserva para alimentar a fila do prestador.',
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
