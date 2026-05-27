import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reservas/presentation/screens/create_reserva_screen.dart';

class SalaoDetailsScreen extends ConsumerWidget {
  const SalaoDetailsScreen({required this.salaoId, super.key});

  final int salaoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salao = ref.watch(salaoProvider(salaoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do salao')),
      body: SafeArea(
        top: false,
        child: AsyncStateView(
          value: salao,
          onRetry: () => ref.invalidate(salaoProvider(salaoId)),
          data: (item) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.teal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_activity_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.endereco,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    icon: Icons.groups_rounded,
                    label: '${item.capacidade} convidados',
                    color: AppTheme.teal,
                  ),
                  const StatusPill(
                    icon: Icons.calendar_month_rounded,
                    label: 'agenda flexivel',
                    color: AppTheme.coral,
                  ),
                  const StatusPill(
                    icon: Icons.verified_rounded,
                    label: 'confirmacao pelo prestador',
                    color: AppTheme.amber,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Descricao',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                item.descricao,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CreateReservaScreen(salao: item),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Solicitar reserva'),
              ),
              const SizedBox(height: 10),
              Text(
                'Depois de enviar, acompanhe a resposta do prestador em Minhas reservas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
