import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/presentation/widgets/async_state_view.dart';
import '../../../../core/presentation/widgets/status_pill.dart';
import '../../../../core/theme/app_theme.dart';
import 'salao_details_screen.dart';
import '../widgets/salao_card.dart';

class SaloesScreen extends ConsumerWidget {
  const SaloesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saloes = ref.watch(saloesProvider);

    return SafeArea(
      top: false,
      child: AsyncStateView(
        value: saloes,
        onRetry: () => ref.invalidate(saloesProvider),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(saloesProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _HeroSummary(total: items.length),
              const SizedBox(height: 18),
              Text(
                'Saloes disponiveis',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final salao in items)
                SalaoCard(
                  salao: salao,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SalaoDetailsScreen(salaoId: salao.id),
                    ),
                  ),
                ),
              if (items.isEmpty)
                const _EmptyList(
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Nenhum salao cadastrado',
                  subtitle: 'Ainda nao ha opcoes disponiveis para reserva.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.coral,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Encontre o espaco certo para sua festa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      icon: Icons.storefront_rounded,
                      label: '$total locais',
                      color: AppTheme.teal,
                    ),
                    const StatusPill(
                      icon: Icons.calendar_month_rounded,
                      label: 'reserva online',
                      color: AppTheme.coral,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
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
