import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

class FilterRentals {
  final RentalRepository repository;

  FilterRentals(this.repository);

  Future<List<Rental>> call({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  }) async {
    return await repository.filterRentals(
      fromDate: fromDate,
      toDate: toDate,
      vehicleNumber: vehicleNumber,
      ownerName: ownerName,
    );
  }
}

