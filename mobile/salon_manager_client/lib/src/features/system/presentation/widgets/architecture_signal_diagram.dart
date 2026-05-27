import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ArchitectureNodeInfo {
  const ArchitectureNodeInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.points,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> points;
}

const architectureNodeInfos = <ArchitectureNodeInfo>[
  ArchitectureNodeInfo(
    id: 'flutter',
    title: 'Flutter Cliente',
    subtitle: 'App do usuario',
    description:
        'E a interface mobile da Sprint 3. O cliente lista saloes, cria reservas e acompanha mudancas sem precisar atualizar manualmente.',
    points: [
      'Entrega as telas de listagem, detalhes, acao principal e acompanhamento.',
      'Consome o backend por HTTP/JSON, mantendo o app simples para o usuario.',
      'Organizado em presentation, domain e data para evidenciar Clean Architecture.',
    ],
  ),
  ArchitectureNodeInfo(
    id: 'api',
    title: 'Backend REST',
    subtitle: 'Node.js + Express',
    description:
        'E o servico que recebe as chamadas dos apps, aplica regras de negocio, grava no banco e publica eventos quando algo importante acontece.',
    points: [
      'Exemplos: GET /api/saloes, POST /api/reservas e PUT /api/reservas/:id/status.',
      'Mantem uma interface REST clara entre app e servidor.',
      'Pode ser replicado atras de um balanceador para reduzir ponto de falha unico.',
    ],
  ),
  ArchitectureNodeInfo(
    id: 'rabbit',
    title: 'RabbitMQ',
    subtitle: 'Middleware assincrono',
    description:
        'E o broker de mensagens. Ele desacopla produtor e consumidor: o backend publica, o consumer processa depois, sem chamada direta entre eles.',
    points: [
      'Usa AMQP 0-9-1, filas duraveis e mensagens persistentes.',
      'Fila do prestador recebe NOVA_RESERVA_CRIADA.',
      'Fila do cliente recebe STATUS_RESERVA_ATUALIZADO.',
    ],
  ),
  ArchitectureNodeInfo(
    id: 'consumer',
    title: 'Consumer',
    subtitle: 'Processo Docker isolado',
    description:
        'E um processo separado do backend. Ele fica escutando as filas, confirma o processamento com ACK e grava evidencias no banco.',
    points: [
      'Demonstra assincronicidade real: nao ha import de codigo nem REST backend -> consumer.',
      'Usa reconexao automatica para tolerar RabbitMQ ainda iniciando.',
      'Pode escalar horizontalmente com mais consumers no padrao Work Queue.',
    ],
  ),
  ArchitectureNodeInfo(
    id: 'postgres',
    title: 'PostgreSQL',
    subtitle: 'Persistencia',
    description:
        'Guarda saloes, clientes, reservas e os eventos processados. E a fonte de verdade consultada pelos endpoints REST.',
    points: [
      'Persistencia relacional deixa o estado das reservas auditavel.',
      'Na evolucao, pode usar replica de leitura, backup e banco gerenciado.',
      'O app mostra o estado mais recente a partir do servidor.',
    ],
  ),
  ArchitectureNodeInfo(
    id: 'eventLog',
    title: 'event_log',
    subtitle: 'Evidencia auditavel',
    description:
        'Tabela que prova que a mensagem passou pelo RabbitMQ e foi processada pelo consumer separado.',
    points: [
      'Ajuda a demonstrar produtor, broker, consumidor e timestamp de processamento.',
      'Serve como base para atualizacao automatica do app por consulta periodica.',
      'Mostra que o fluxo nao depende de uma chamada REST direta ao consumer.',
    ],
  ),
];

class ArchitectureSignalDiagram extends StatefulWidget {
  const ArchitectureSignalDiagram({required this.onNodeSelected, super.key});

  final ValueChanged<ArchitectureNodeInfo> onNodeSelected;

  @override
  State<ArchitectureSignalDiagram> createState() =>
      _ArchitectureSignalDiagramState();
}

class _ArchitectureSignalDiagramState extends State<ArchitectureSignalDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final layout = _ArchitectureLayout.fromSize(size);
              return Stack(
                children: [
                  CustomPaint(
                    painter: _ArchitecturePainter(
                      progress: _controller.value,
                      layout: layout,
                    ),
                    child: const SizedBox.expand(),
                  ),
                  for (final entry in layout.nodes.entries)
                    Positioned(
                      left: entry.value.left,
                      top: entry.value.top,
                      width: entry.value.width,
                      height: entry.value.height,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => widget.onNodeSelected(
                            architectureNodeInfos.firstWhere(
                              (node) => node.id == entry.key,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ArchitectureLayout {
  const _ArchitectureLayout({required this.nodes});

  final Map<String, Rect> nodes;

  factory _ArchitectureLayout.fromSize(Size size) {
    final nodeWidth = math.min(114.0, size.width * 0.31);
    const nodeHeight = 46.0;
    const margin = 14.0;

    return _ArchitectureLayout(
      nodes: {
        'flutter': Rect.fromLTWH(margin, 22, nodeWidth, nodeHeight),
        'api': Rect.fromLTWH(
          (size.width - nodeWidth) / 2,
          22,
          nodeWidth,
          nodeHeight,
        ),
        'rabbit': Rect.fromLTWH(
          size.width - nodeWidth - margin,
          22,
          nodeWidth,
          nodeHeight,
        ),
        'postgres': Rect.fromLTWH(
          (size.width - nodeWidth) / 2,
          size.height - nodeHeight - 22,
          nodeWidth,
          nodeHeight,
        ),
        'eventLog': Rect.fromLTWH(
          margin,
          size.height - nodeHeight - 22,
          nodeWidth,
          nodeHeight,
        ),
        'consumer': Rect.fromLTWH(
          size.width - nodeWidth - margin,
          size.height - nodeHeight - 22,
          nodeWidth,
          nodeHeight,
        ),
      },
    );
  }
}

class _ArchitecturePainter extends CustomPainter {
  const _ArchitecturePainter({required this.progress, required this.layout});

  final double progress;
  final _ArchitectureLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final flutter = layout.nodes['flutter']!;
    final api = layout.nodes['api']!;
    final rabbit = layout.nodes['rabbit']!;
    final postgres = layout.nodes['postgres']!;
    final eventLog = layout.nodes['eventLog']!;
    final consumer = layout.nodes['consumer']!;

    _drawLine(canvas, flutter.centerRight, api.centerLeft, AppTheme.teal);
    _drawLine(canvas, api.centerRight, rabbit.centerLeft, AppTheme.coral);
    _drawLine(canvas, rabbit.bottomCenter, consumer.topCenter, AppTheme.coral);
    _drawLine(
      canvas,
      consumer.centerLeft,
      postgres.centerRight,
      AppTheme.amber,
    );
    _drawLine(canvas, api.bottomCenter, postgres.topCenter, AppTheme.teal);
    _drawLine(
      canvas,
      postgres.centerLeft,
      eventLog.centerRight,
      Colors.blueGrey,
    );

    _drawPulse(
      canvas,
      flutter.centerRight,
      api.centerLeft,
      progress,
      AppTheme.teal,
    );
    _drawPulse(
      canvas,
      api.centerRight,
      rabbit.centerLeft,
      (progress + 0.2) % 1,
      AppTheme.coral,
    );
    _drawPulse(
      canvas,
      rabbit.bottomCenter,
      consumer.topCenter,
      (progress + 0.42) % 1,
      AppTheme.coral,
    );
    _drawPulse(
      canvas,
      consumer.centerLeft,
      postgres.centerRight,
      (progress + 0.62) % 1,
      AppTheme.amber,
    );
    _drawPulse(
      canvas,
      api.bottomCenter,
      postgres.topCenter,
      (progress + 0.78) % 1,
      AppTheme.teal,
    );

    _drawNode(canvas, flutter, 'Flutter', 'Cliente', AppTheme.teal);
    _drawNode(canvas, api, 'REST API', 'Express', AppTheme.teal);
    _drawNode(canvas, rabbit, 'RabbitMQ', 'MOM', AppTheme.coral);
    _drawNode(canvas, consumer, 'Consumer', 'ACK', AppTheme.coral);
    _drawNode(canvas, postgres, 'Postgres', 'Dados', AppTheme.amber);
    _drawNode(canvas, eventLog, 'event_log', 'evidencia', Colors.blueGrey);
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.36)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  void _drawPulse(
    Canvas canvas,
    Offset start,
    Offset end,
    double t,
    Color color,
  ) {
    final offset = Offset.lerp(start, end, t)!;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final dot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, 10, glow);
    canvas.drawCircle(offset, 4.8, dot);
  }

  void _drawNode(
    Canvas canvas,
    Rect rect,
    String title,
    String subtitle,
    Color color,
  ) {
    final background = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rounded, background);
    canvas.drawRRect(rounded, border);

    _drawText(
      canvas,
      title,
      Offset(rect.left + 10, rect.top + 8),
      12,
      FontWeight.w900,
      AppTheme.ink,
      rect.width - 20,
    );
    _drawText(
      canvas,
      subtitle,
      Offset(rect.left + 10, rect.top + 26),
      10,
      FontWeight.w700,
      color,
      rect.width - 20,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double fontSize,
    FontWeight weight,
    Color color,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      maxLines: 1,
      ellipsis: '.',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ArchitecturePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
