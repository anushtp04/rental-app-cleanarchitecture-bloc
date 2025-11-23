import '../../domain/entities/rental.dart';
import '../../domain/repositories/rental_repository.dart';
import '../data_source/rental_local_data_source.dart';
import '../models/rental_model.dart';

class RentalRepositoryImpl implements RentalRepository {
  final RentalLocalDataSource localDataSource;

  RentalRepositoryImpl(this.localDataSource);

  @override
  Future<List<Rental>> getAllRentals() async {
    final rentals = await localDataSource.getAllRentals();
    return rentals.map((rental) => rental.toEntity()).toList();
  }

  @override
  Future<Rental> getRentalById(String id) async {
    final rental = await localDataSource.getRentalById(id);
    return rental.toEntity();
  }

  @override
  Future<Rental> createRental(Rental rental) async {
    final rentalModel = RentalModel.fromEntity(rental);
    await localDataSource.cacheRental(rentalModel);
    return rentalModel.toEntity();
  }

  @override
  Future<Rental> updateRental(Rental rental) async {
    final rentalModel = RentalModel.fromEntity(rental);
    await localDataSource.updateCachedRental(rentalModel);
    return rentalModel.toEntity();
  }

  @override
  Future<void> deleteRental(String id) async {
    await localDataSource.deleteRental(id);
  }

  @override
  Future<void> deleteAllRentals() async {
    await localDataSource.deleteAllRentals();
  }

  @override
  Future<List<Rental>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  }) async {
    final rentals = await localDataSource.filterRentals(
      fromDate: fromDate,
      toDate: toDate,
      vehicleNumber: vehicleNumber,
      ownerName: ownerName, // This is actually rentToPerson now
    );
    return rentals.map((rental) => rental.toEntity()).toList();
  }
}

