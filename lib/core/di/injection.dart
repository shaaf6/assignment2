import 'package:firebase_service/firebase_service.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<AuthService>(() => FirebaseAuthServiceImpl());
  sl.registerLazySingleton<FirestoreService>(
      () => FirebaseFirestoreServiceImpl());
}
