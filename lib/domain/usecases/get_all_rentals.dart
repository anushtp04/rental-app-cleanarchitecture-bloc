import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

class GetAllRentals {
  final RentalRepository repository;

  GetAllRentals(this.repository);

  Future<List<Rental>> call() async {
    return await repository.getAllRentals();
  }
}

