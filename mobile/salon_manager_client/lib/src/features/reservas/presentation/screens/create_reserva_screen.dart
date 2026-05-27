import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../saloes/domain/entities/salao.dart';
import '../../domain/entities/reserva.dart';
import '../controllers/reservas_feed_controller.dart';

class CreateReservaScreen extends ConsumerStatefulWidget {
  const CreateReservaScreen({required this.salao, super.key});

  final Salao salao;

  @override
  ConsumerState<CreateReservaScreen> createState() => _CreateReservaScreenState();
}

class _CreateReservaScreenState extends ConsumerState<CreateReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController(text: 'Arthur Mendonca');
  final _emailController =
      TextEditingController(text: 'arthur.mendonca.1352200@sga.pucminas.br');
  final _telefoneController = TextEditingController(text: '+55 31 99999-0000');

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 14));
    _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = ref.watch(
      reservasFeedControllerProvider.select((state) => state.isCreating),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Nova reserva')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _SelectedSalaoPanel(salao: widget.salao),
              const SizedBox(height: 18),
              Text(
                'Dados do cliente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (value) =>
                    value == null || value.trim().length < 3
                        ? 'Informe o nome completo'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  return text.contains('@') ? null : 'Informe um e-mail valido';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Informe um telefone' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Data e horario',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.calendar_today_rounded,
                      label: DateFormatters.day(_selectedDate),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule_rounded,
                      label: _selectedTime.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: isCreating ? null : _submit,
                icon: isCreating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(isCreating ? 'Enviando...' : 'Enviar solicitacao'),
              ),
              const SizedBox(height: 12),
              Text(
                'A solicitacao aparece em Minhas reservas assim que o backend confirma o POST /api/reservas.',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (dateTime.isBefore(DateTime.now())) {
      _showMessage('Escolha uma data futura para a reserva');
      return;
    }

    try {
      final reserva = await ref
          .read(reservasFeedControllerProvider.notifier)
          .createReserva(
            ReservaDraft(
              salaoId: widget.salao.id,
              dataReserva: dateTime,
              clienteNome: _nomeController.text.trim(),
              clienteEmail: _emailController.text.trim(),
              clienteTelefone: _telefoneController.text.trim(),
            ),
          );

      if (!mounted) return;
      _showMessage('Reserva #${reserva.id} criada e aguardando confirmacao');
      Navigator.of(context).pop();
    } catch (err) {
      if (!mounted) return;
      _showMessage('Falha ao criar reserva: $err');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SelectedSalaoPanel extends StatelessWidget {
  const _SelectedSalaoPanel({required this.salao});

  final Salao salao;

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.mint.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salao.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  salao.endereco,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
