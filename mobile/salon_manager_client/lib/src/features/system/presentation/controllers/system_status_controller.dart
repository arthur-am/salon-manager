import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/system_status.dart';

final systemStatusControllerProvider =
    NotifierProvider<SystemStatusController, AsyncValue<SystemStatus>>(
  SystemStatusController.new,
);

class SystemStatusController extends Notifier<AsyncValue<SystemStatus>> {
  Timer? _timer;

  @override
  AsyncValue<SystemStatus> build() {
    _timer?.cancel();
    _timer = Timer.periodic(
      ApiConfig.systemPollingInterval,
      (_) => refresh(silent: true),
    );
    ref.onDispose(() => _timer?.cancel());
    Future.microtask(refresh);
    return const AsyncLoading<SystemStatus>();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = const AsyncLoading<SystemStatus>();
    try {
      final status = await ref.read(getSystemStatusProvider)();
      state = AsyncData(status);
    } catch (err, stackTrace) {
      state = AsyncError<SystemStatus>(err, stackTrace);
    }
  }
}
