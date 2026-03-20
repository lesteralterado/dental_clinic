import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../presentation/blocs/theme/theme_bloc.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/patient_repository.dart';
import '../data/repositories/appointment_repository.dart';
import '../data/repositories/dashboard_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  // Core
  sl.registerLazySingleton(() => ApiClient(secureStorage: sl()));

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(apiClient: sl()));
  sl.registerLazySingleton(() => PatientRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AppointmentRepository(apiClient: sl()));
  sl.registerLazySingleton(() => DashboardRepository(apiClient: sl()));

  // BLoCs
  sl.registerFactory(() => ThemeBloc());
  sl.registerFactory(() => AuthBloc(
        authRepository: sl(),
      ));
}
