import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../presentation/blocs/theme/theme_bloc.dart';
import '../presentation/blocs/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => ThemeBloc());
  sl.registerFactory(() => AuthBloc(apiClient: sl()));

  // Core
  sl.registerLazySingleton(() => ApiClient());
}
