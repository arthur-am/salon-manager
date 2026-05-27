import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ArchitectureSignalDiagram extends StatefulWidget {
  const ArchitectureSignalDiagram({super.key});

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
          return CustomPaint(
            painter: _ArchitecturePainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ArchitecturePainter extends CustomPainter {
  const _ArchitecturePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = math.min(114.0, size.width * 0.31);
    const nodeHeight = 46.0;
    const margin = 14.0;

    final flutter = Rect.fromLTWH(margin, 22, nodeWidth, nodeHeight);
    final api = Rect.fromLTWH(
      (size.width - nodeWidth) / 2,
      22,
      nodeWidth,
      nodeHeight,
    );
    final rabbit = Rect.fromLTWH(
      size.width - nodeWidth - margin,
      22,
      nodeWidth,
      nodeHeight,
    );
    final postgres = Rect.fromLTWH(
      (size.width - nodeWidth) / 2,
      size.height - nodeHeight - 22,
      nodeWidth,
      nodeHeight,
    );
    final eventLog = Rect.fromLTWH(
      margin,
      size.height - nodeHeight - 22,
      nodeWidth,
      nodeHeight,
    );
    final consumer = Rect.fromLTWH(
      size.width - nodeWidth - margin,
      size.height - nodeHeight - 22,
      nodeWidth,
      nodeHeight,
    );

    _drawLine(canvas, flutter.centerRight, api.centerLeft, AppTheme.teal);
    _drawLine(canvas, api.centerRight, rabbit.centerLeft, AppTheme.coral);
    _drawLine(canvas, rabbit.bottomCenter, consumer.topCenter, AppTheme.coral);
    _drawLine(canvas, consumer.centerLeft, postgres.centerRight, AppTheme.amber);
    _drawLine(canvas, api.bottomCenter, postgres.topCenter, AppTheme.teal);
    _drawLine(canvas, postgres.centerLeft, eventLog.centerRight, Colors.blueGrey);

    _drawPulse(canvas, flutter.centerRight, api.centerLeft, progress, AppTheme.teal);
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

  void _drawNode(Canvas canvas, Rect rect, String title, String subtitle, Color color) {
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
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
        ),
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
