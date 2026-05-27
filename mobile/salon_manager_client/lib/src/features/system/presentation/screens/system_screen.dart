import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../reservas/presentation/controllers/reservas_feed_controller.dart';
import '../../../reservas/presentation/widgets/event_log_tile.dart';
import '../controllers/system_status_controller.dart';
import '../widgets/architecture_signal_diagram.dart';

class SystemScreen extends ConsumerWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(systemStatusControllerProvider);
    final controller = ref.read(systemStatusControllerProvider.notifier);
    final reservasState = ref.watch(reservasFeedControllerProvider);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.refresh();
          await ref.read(reservasFeedControllerProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            ArchitectureSignalDiagram(
              onNodeSelected: (node) => _showInfoSheet(
                context,
                title: node.title,
                subtitle: node.subtitle,
                description: node.description,
                points: node.points,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Toque em uma caixa do desenho para ver o papel dela no sistema.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      StatusPill(
                        icon: snapshot.healthy
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        label: snapshot.status.toUpperCase(),
                        color: snapshot.healthy
                            ? AppTheme.teal
                            : AppTheme.coral,
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
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'API REST',
                      subtitle: 'Integracao correta com o backend',
                      description:
                          'E a porta de entrada dos apps. A Sprint 3 prova essa integracao ao listar saloes, criar cliente, criar reserva e alterar status por endpoints REST.',
                      points: const [
                        'GET /api/saloes lista os servicos disponiveis.',
                        'POST /api/reservas cria a solicitacao do cliente.',
                        'PUT /api/reservas/:id/status permite aceitar, recusar ou concluir.',
                      ],
                    ),
                  ),
                  _ServiceTile(
                    icon: Icons.storage_rounded,
                    title: 'PostgreSQL',
                    value: snapshot.database.connected
                        ? '${snapshot.database.latencyMs ?? 0} ms'
                        : snapshot.database.error ?? 'indisponivel',
                    color: AppTheme.amber,
                    healthy: snapshot.database.connected,
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'PostgreSQL',
                      subtitle: 'Estado confiavel',
                      description:
                          'Guarda clientes, saloes, reservas e event_log. Isso deixa o fluxo demonstravel e auditavel para a avaliacao.',
                      points: const [
                        'As reservas mudam de PENDENTE para CONFIRMADA, RECUSADA ou CONCLUIDA.',
                        'O event_log registra evidencias dos eventos processados.',
                        'Em producao, pode receber backup e replicas para reduzir risco.',
                      ],
                    ),
                  ),
                  _ServiceTile(
                    icon: Icons.mark_email_unread_rounded,
                    title: 'RabbitMQ publisher',
                    value: snapshot.messaging.connected
                        ? '${snapshot.messaging.queues.length} filas duraveis'
                        : snapshot.messaging.lastError ?? 'reconectando',
                    color: AppTheme.coral,
                    healthy: snapshot.messaging.connected,
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'RabbitMQ',
                      subtitle: 'Middleware verdadeiramente assincrono',
                      description:
                          'O backend publica mensagens em filas e o consumer processa depois. Isso evita acoplamento direto e mostra assincronicidade real.',
                      points: const [
                        'fila_notificacoes_prestador recebe novas reservas.',
                        'fila_notificacoes_cliente recebe mudancas de status.',
                        'Filas duraveis e mensagens persistentes reduzem perda em falhas.',
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Conceitos que valem ponto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ConceptGrid(
                    onTap: (concept) => _showInfoSheet(
                      context,
                      title: concept.title,
                      subtitle: concept.subtitle,
                      description: concept.description,
                      points: concept.points,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Evidencias recentes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const StatusPill(
                        icon: Icons.fact_check_rounded,
                        label: 'event_log',
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AsyncStateView(
                    value: reservasState.events,
                    onRetry: () => ref
                        .read(reservasFeedControllerProvider.notifier)
                        .refresh(),
                    loadingLabel: 'Lendo evidencias',
                    data: (events) {
                      if (events.isEmpty) {
                        return const _EvidenceEmpty();
                      }
                      return Column(
                        children: [
                          for (final event in events.take(6))
                            EventLogTile(event: event),
                        ],
                      );
                    },
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

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required List<String> points,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.88,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 16),
              for (final point in points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.teal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(point)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.healthy,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool healthy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
        ),
      ),
    );
  }
}

class _Concept {
  const _Concept({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.points,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> points;
}

const _concepts = [
  _Concept(
    icon: Icons.warning_amber_rounded,
    title: 'Ponto de falha unica',
    subtitle: 'Onde o sistema ainda pode parar',
    description:
        'Um ponto de falha unica e qualquer componente que, se cair sozinho, derruba uma parte importante do sistema.',
    points: [
      'Hoje o banco e o broker sao pontos centrais.',
      'O app mostra essa consciencia na tela Sistema.',
      'A mitigacao vem com replicas, backups, broker gerenciado e balanceamento.',
    ],
  ),
  _Concept(
    icon: Icons.account_tree_rounded,
    title: 'Redundancia',
    subtitle: 'Como reduzir risco',
    description:
        'Redundancia significa ter mais de uma instancia ou copia de um componente critico para o sistema continuar operando se algo falhar.',
    points: [
      'Mais de um backend atras de um load balancer.',
      'Mais de um consumer processando a mesma fila.',
      'Banco com backup e replica de leitura.',
    ],
  ),
  _Concept(
    icon: Icons.trending_up_rounded,
    title: 'Escalabilidade',
    subtitle: 'Crescer sem reescrever tudo',
    description:
        'A arquitetura permite crescer em partes. O produtor nao precisa conhecer quantos consumers existem.',
    points: [
      'Work Queue permite adicionar consumers.',
      'Backend pode ser replicado horizontalmente.',
      'App continua chamando a mesma API.',
    ],
  ),
  _Concept(
    icon: Icons.sync_alt_rounded,
    title: 'Assincronicidade real',
    subtitle: 'Sem REST direto ao consumer',
    description:
        'O fluxo e assincrono porque o backend publica no RabbitMQ e segue a vida. O consumer processa depois, em processo separado.',
    points: [
      'Backend e consumer sao containers diferentes.',
      'A unica ponte entre eles e o RabbitMQ.',
      'O event_log prova o processamento posterior.',
    ],
  ),
  _Concept(
    icon: Icons.send_rounded,
    title: 'Produtor e consumidor',
    subtitle: 'Eventos do dominio',
    description:
        'O backend e o produtor dos eventos. O consumer e quem recebe, confirma e registra os eventos.',
    points: [
      'NOVA_RESERVA_CRIADA vai para o prestador.',
      'STATUS_RESERVA_ATUALIZADO vai para o cliente.',
      'ACK manual evita remover mensagem antes do processamento.',
    ],
  ),
  _Concept(
    icon: Icons.layers_rounded,
    title: 'Clean Architecture',
    subtitle: 'Codigo organizado por responsabilidade',
    description:
        'O app Flutter separa tela, estado, casos de uso, contratos, modelos e cliente HTTP.',
    points: [
      'presentation: telas, widgets e controllers.',
      'domain: entidades, contratos e casos de uso.',
      'data: modelos JSON e chamadas REST.',
    ],
  ),
  _Concept(
    icon: Icons.cloud_done_rounded,
    title: 'Atualizacao automatica',
    subtitle: 'Estado muda sem acao manual',
    description:
        'O app consulta periodicamente reservas e event_log. Assim, quando o prestador aceita uma reserva, o cliente ve a mudanca sozinho.',
    points: [
      'Atende ao criterio de atualizacao assincrona de estado.',
      'Evita que o usuario precise apertar atualizar.',
      'Pode evoluir para WebSocket ou push na proxima sprint.',
    ],
  ),
  _Concept(
    icon: Icons.touch_app_rounded,
    title: 'Interface clara',
    subtitle: 'Tecnico no lugar certo',
    description:
        'As abas de uso falam a lingua do usuario. A aba Sistema concentra a explicacao tecnica para avaliacao.',
    points: [
      'Cliente cria e acompanha reservas.',
      'Prestador aceita, recusa e conclui.',
      'Sistema explica arquitetura, resiliencia e evidencias.',
    ],
  ),
];

class _ConceptGrid extends StatelessWidget {
  const _ConceptGrid({required this.onTap});

  final ValueChanged<_Concept> onTap;

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
          childAspectRatio: columns == 1 ? 4.4 : 3.2,
          children: [
            for (final concept in _concepts)
              _ConceptCard(concept: concept, onTap: () => onTap(concept)),
          ],
        );
      },
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.concept, required this.onTap});

  final _Concept concept;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(concept.icon, color: AppTheme.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  concept.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceEmpty extends StatelessWidget {
  const _EvidenceEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        'Crie ou atualize uma reserva para ver eventos processados aqui.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
