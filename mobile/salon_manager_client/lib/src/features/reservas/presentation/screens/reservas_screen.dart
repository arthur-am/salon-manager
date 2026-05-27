import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/reserva.dart';
import '../controllers/reservas_feed_controller.dart';
import '../widgets/reserva_card.dart';

enum _ReservasMode { cliente, prestador }

class ReservasScreen extends ConsumerStatefulWidget {
  const ReservasScreen({super.key});

  @override
  ConsumerState<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends ConsumerState<ReservasScreen> {
  _ReservasMode _mode = _ReservasMode.cliente;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            SegmentedButton<_ReservasMode>(
              segments: const [
                ButtonSegment(
                  value: _ReservasMode.cliente,
                  icon: Icon(Icons.person_rounded),
                  label: Text('Cliente'),
                ),
                ButtonSegment(
                  value: _ReservasMode.prestador,
                  icon: Icon(Icons.manage_accounts_rounded),
                  label: Text('Prestador'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) {
                setState(() => _mode = value.first);
              },
            ),
            const SizedBox(height: 18),
            Text(
              _mode == _ReservasMode.cliente
                  ? 'Minhas reservas'
                  : 'Solicitacoes recebidas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              _mode == _ReservasMode.cliente
                  ? 'Acompanhe suas reservas sem precisar atualizar a tela.'
                  : 'Aceite, recuse ou conclua as reservas solicitadas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            AsyncStateView(
              value: state.reservas,
              onRetry: controller.refresh,
              loadingLabel: 'Atualizando reservas',
              data: (reservas) {
                final visible = _mode == _ReservasMode.cliente
                    ? reservas
                    : _sortForManager(reservas);

                if (visible.isEmpty) {
                  return _EmptyReservations(mode: _mode);
                }

                return Column(
                  children: [
                    for (final reserva in visible.take(12))
                      ReservaCard(
                        reserva: reserva,
                        showManagerActions: _mode == _ReservasMode.prestador,
                        isUpdating: state.updatingReservaId == reserva.id,
                        onConfirm: () => _updateStatus(
                          reserva,
                          'CONFIRMADA',
                          'Reserva aceita',
                        ),
                        onReject: () => _updateStatus(
                          reserva,
                          'RECUSADA',
                          'Reserva recusada',
                        ),
                        onComplete: () => _updateStatus(
                          reserva,
                          'CONCLUIDA',
                          'Reserva concluida',
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Reserva> _sortForManager(List<Reserva> reservas) {
    final sorted = [...reservas];
    int weight(Reserva reserva) {
      if (reserva.isPending) return 0;
      if (reserva.isConfirmed) return 1;
      return 2;
    }

    sorted.sort((a, b) {
      final byStatus = weight(a).compareTo(weight(b));
      if (byStatus != 0) return byStatus;
      return a.dataReserva.compareTo(b.dataReserva);
    });
    return sorted;
  }

  Future<void> _updateStatus(
    Reserva reserva,
    String status,
    String successMessage,
  ) async {
    try {
      await ref
          .read(reservasFeedControllerProvider.notifier)
          .updateStatus(reserva.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successMessage: #${reserva.id}')),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel atualizar: $err')),
      );
    }
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
            child: const Icon(Icons.autorenew_rounded, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservas sempre atualizadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lastSync == null
                      ? 'Preparando sua lista.'
                      : 'Atualizado em ${DateFormatters.compact(lastSync!)}',
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
  const _EmptyReservations({required this.mode});

  final _ReservasMode mode;

  @override
  Widget build(BuildContext context) {
    return _EmptyPanel(
      icon: mode == _ReservasMode.cliente
          ? Icons.event_busy_rounded
          : Icons.assignment_turned_in_outlined,
      title: mode == _ReservasMode.cliente
          ? 'Nenhuma reserva ainda'
          : 'Nenhuma solicitacao recebida',
      subtitle: mode == _ReservasMode.cliente
          ? 'Escolha um salao e envie a primeira solicitacao.'
          : 'Quando um cliente solicitar uma reserva, ela aparece aqui.',
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
