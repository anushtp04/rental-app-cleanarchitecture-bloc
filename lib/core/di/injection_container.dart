import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/data_source/rental_supabase_data_source.dart';
import '../../data/data_source/car_supabase_data_source.dart';
import '../../data/repositories/rental_repository_impl.dart';
import '../../data/repositories/car_repository_impl.dart';
import '../../data/models/rental_model.dart';
import '../../data/models/car_model.dart';
import '../../domain/repositories/rental_repository.dart';
import '../../domain/repositories/car_repository.dart';
import '../../domain/usecases/get_all_rentals.dart';
import '../../domain/usecases/create_rental.dart';
import '../../domain/usecases/update_rental.dart';
import '../../domain/usecases/delete_rental.dart';
import '../../domain/usecases/filter_rentals.dart';
import '../../domain/usecases/car_usecases.dart';
import '../../presentation/bloc/rental/rental_bloc.dart';
import '../../presentation/bloc/car/car_bloc.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../core/service/supabase_auth_service.dart';
import '../../core/service/supabase_storage_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(RentalModelAdapter());
  Hive.registerAdapter(CarModelAdapter());
  
  // Open Hive Boxes
  await Hive.openBox<RentalModel>('rentals');
  await Hive.openBox<CarModel>('cars');
  await Hive.openBox('theme'); // For theme preferences

  // Services
  sl.registerLazySingleton<SupabaseAuthService>(() => SupabaseAuthService());
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<SupabaseStorageService>(() => SupabaseStorageService(sl()));

  // Data Sources - Supabase
  sl.registerLazySingleton<RentalSupabaseDataSource>(
    () => RentalSupabaseDataSourceImpl(
      supabase: sl(),
      authService: sl(),
      storageService: sl(),
    ),
  );

  sl.registerLazySingleton<CarSupabaseDataSource>(
    () => CarSupabaseDataSourceImpl(
      supabase: sl(),
      authService: sl(),
      storageService: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(() => ThemeBloc());
  
  sl.registerFactory(
    () => AuthBloc(sl())..add(AuthCheckRequested()),
  );
  
  sl.registerFactory(
    () => RentalBloc(
      getAllRentals: sl(),
      createRental: sl(),
      updateRental: sl(),
      deleteRental: sl(),
      filterRentals: sl(),
    )..add(LoadRentals()),
  );

  sl.registerFactory(
    () => CarBloc(
      getAllCars: sl(),
      addCar: sl(),
      updateCar: sl(),
      deleteCar: sl(),
    )..add(LoadCars()),
  );

  // Rental Use cases
  sl.registerLazySingleton(() => GetAllRentals(sl()));
  sl.registerLazySingleton(() => CreateRental(sl()));
  sl.registerLazySingleton(() => UpdateRental(sl()));
  sl.registerLazySingleton(() => DeleteRental(sl()));
  sl.registerLazySingleton(() => FilterRentals(sl()));

  // Car Use cases
  sl.registerLazySingleton(() => GetAllCars(sl()));
  sl.registerLazySingleton(() => AddCar(sl()));
  sl.registerLazySingleton(() => UpdateCar(sl()));
  sl.registerLazySingleton(() => DeleteCar(sl()));

  // Rental Repository
  sl.registerLazySingleton<RentalRepository>(
    () => RentalRepositoryImpl(sl<RentalSupabaseDataSource>()),
  );

  // Car Repository
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(sl<CarSupabaseDataSource>()),
  );
}
