import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../features/client/data/repositories/clientes_repository_impl.dart';
import '../features/client/domain/repositories/clientes_repository.dart';
import '../features/reservas/data/repositories/reservas_repository_impl.dart';
import '../features/reservas/domain/repositories/reservas_repository.dart';
import '../features/reservas/domain/usecases/create_reserva_flow.dart';
import '../features/reservas/domain/usecases/update_reserva_status.dart';
import '../features/reservas/domain/usecases/watch_reservas_snapshot.dart';
import '../features/saloes/data/repositories/saloes_repository_impl.dart';
import '../features/saloes/domain/entities/salao.dart';
import '../features/saloes/domain/repositories/saloes_repository.dart';
import '../features/saloes/domain/usecases/get_salao.dart';
import '../features/saloes/domain/usecases/list_saloes.dart';
import '../features/system/data/repositories/system_repository_impl.dart';
import '../features/system/domain/repositories/system_repository.dart';
import '../features/system/domain/usecases/get_system_status.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final saloesRepositoryProvider = Provider<SaloesRepository>(
  (ref) => SaloesRepositoryImpl(ref.watch(apiClientProvider)),
);

final clientesRepositoryProvider = Provider<ClientesRepository>(
  (ref) => ClientesRepositoryImpl(ref.watch(apiClientProvider)),
);

final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryImpl(ref.watch(apiClientProvider)),
);

final systemRepositoryProvider = Provider<SystemRepository>(
  (ref) => SystemRepositoryImpl(ref.watch(apiClientProvider)),
);

final listSaloesUseCaseProvider = Provider<ListSaloes>(
  (ref) => ListSaloes(ref.watch(saloesRepositoryProvider)),
);

final getSalaoUseCaseProvider = Provider<GetSalao>(
  (ref) => GetSalao(ref.watch(saloesRepositoryProvider)),
);

final createReservaFlowProvider = Provider<CreateReservaFlow>(
  (ref) => CreateReservaFlow(
    ref.watch(clientesRepositoryProvider),
    ref.watch(reservasRepositoryProvider),
  ),
);

final watchReservasSnapshotProvider = Provider<WatchReservasSnapshot>(
  (ref) => WatchReservasSnapshot(ref.watch(reservasRepositoryProvider)),
);

final updateReservaStatusProvider = Provider<UpdateReservaStatus>(
  (ref) => UpdateReservaStatus(ref.watch(reservasRepositoryProvider)),
);

final getSystemStatusProvider = Provider<GetSystemStatus>(
  (ref) => GetSystemStatus(ref.watch(systemRepositoryProvider)),
);

final saloesProvider = FutureProvider<List<Salao>>(
  (ref) => ref.watch(listSaloesUseCaseProvider)(),
);

final salaoProvider = FutureProvider.family<Salao, int>(
  (ref, id) => ref.watch(getSalaoUseCaseProvider)(id),
);
