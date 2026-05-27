import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/event_log.dart';
import '../../domain/entities/reserva.dart';

final reservasFeedControllerProvider =
    NotifierProvider<ReservasFeedController, ReservasFeedState>(
  ReservasFeedController.new,
);

class ReservasFeedState {
  const ReservasFeedState({
    required this.reservas,
    required this.events,
    required this.isCreating,
    required this.lastSync,
  });

  factory ReservasFeedState.initial() {
    return const ReservasFeedState(
      reservas: AsyncLoading<List<Reserva>>(),
      events: AsyncLoading<List<EventLog>>(),
      isCreating: false,
      lastSync: null,
    );
  }

  final AsyncValue<List<Reserva>> reservas;
  final AsyncValue<List<EventLog>> events;
  final bool isCreating;
  final DateTime? lastSync;

  ReservasFeedState copyWith({
    AsyncValue<List<Reserva>>? reservas,
    AsyncValue<List<EventLog>>? events,
    bool? isCreating,
    DateTime? lastSync,
  }) {
    return ReservasFeedState(
      reservas: reservas ?? this.reservas,
      events: events ?? this.events,
      isCreating: isCreating ?? this.isCreating,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

class ReservasFeedController extends Notifier<ReservasFeedState> {
  Timer? _timer;

  @override
  ReservasFeedState build() {
    _timer?.cancel();
    _timer = Timer.periodic(
      ApiConfig.pollingInterval,
      (_) => refresh(silent: true),
    );
    ref.onDispose(() => _timer?.cancel());
    Future.microtask(refresh);
    return ReservasFeedState.initial();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(
        reservas: const AsyncLoading<List<Reserva>>(),
        events: const AsyncLoading<List<EventLog>>(),
      );
    }

    try {
      final snapshot = await ref.read(watchReservasSnapshotProvider)();
      state = state.copyWith(
        reservas: AsyncData(snapshot.reservas),
        events: AsyncData(snapshot.events),
        lastSync: snapshot.syncedAt,
      );
    } catch (err, stackTrace) {
      state = state.copyWith(
        reservas: AsyncError<List<Reserva>>(err, stackTrace),
        events: AsyncError<List<EventLog>>(err, stackTrace),
      );
    }
  }

  Future<Reserva> createReserva(ReservaDraft draft) async {
    state = state.copyWith(isCreating: true);
    try {
      final reserva = await ref.read(createReservaFlowProvider)(draft);
      await refresh(silent: true);
      return reserva;
    } finally {
      state = state.copyWith(isCreating: false);
    }
  }
}
