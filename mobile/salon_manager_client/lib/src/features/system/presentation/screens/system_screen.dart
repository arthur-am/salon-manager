import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../controllers/system_status_controller.dart';
import '../widgets/architecture_signal_diagram.dart';

class SystemScreen extends ConsumerWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(systemStatusControllerProvider);
    final controller = ref.read(systemStatusControllerProvider.notifier);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const ArchitectureSignalDiagram(),
            const SizedBox(height: 18),
            AsyncStateView(
              value: status,
              onRetry: controller.refresh,
              loadingLabel: 'Verificando saude do sistema',
              data: (snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Saude distribuida',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      StatusPill(
                        icon: snapshot.healthy
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        label: snapshot.status.toUpperCase(),
                        color: snapshot.healthy ? AppTheme.teal : AppTheme.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ServiceTile(
                    icon: Icons.api_rounded,
                    title: 'API REST',
                    value: 'Uptime ${_formatUptime(snapshot.uptimeSeconds)}',
                    color: AppTheme.teal,
                    healthy: true,
                  ),
                  _ServiceTile(
                    icon: Icons.storage_rounded,
                    title: 'PostgreSQL',
                    value: snapshot.database.connected
                        ? '${snapshot.database.latencyMs ?? 0} ms'
                        : snapshot.database.error ?? 'indisponivel',
                    color: AppTheme.amber,
                    healthy: snapshot.database.connected,
                  ),
                  _ServiceTile(
                    icon: Icons.mark_email_unread_rounded,
                    title: 'RabbitMQ publisher',
                    value: snapshot.messaging.connected
                        ? '${snapshot.messaging.queues.length} filas duraveis'
                        : snapshot.messaging.lastError ?? 'reconectando',
                    color: AppTheme.coral,
                    healthy: snapshot.messaging.connected,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Controles de resiliencia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ResilienceGrid(
                    items: [
                      _ResilienceItem(
                        icon: Icons.timer_rounded,
                        label: snapshot.resilience.rest,
                      ),
                      _ResilienceItem(
                        icon: Icons.sync_rounded,
                        label: snapshot.resilience.stateSync,
                      ),
                      _ResilienceItem(
                        icon: Icons.queue_rounded,
                        label: snapshot.resilience.mom,
                      ),
                      _ResilienceItem(
                        icon: Icons.account_tree_rounded,
                        label: snapshot.resilience.nextSprint,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Status lido em ${DateFormatters.compact(snapshot.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUptime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.healthy,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            healthy ? Icons.check_circle_rounded : Icons.error_rounded,
            color: healthy ? AppTheme.teal : AppTheme.coral,
          ),
        ],
      ),
    );
  }
}

class _ResilienceGrid extends StatelessWidget {
  const _ResilienceGrid({required this.items});

  final List<_ResilienceItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 1 ? 4.2 : 3.2,
          children: items,
        );
      },
    );
  }
}

class _ResilienceItem extends StatelessWidget {
  const _ResilienceItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.isEmpty ? 'nao informado' : label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
