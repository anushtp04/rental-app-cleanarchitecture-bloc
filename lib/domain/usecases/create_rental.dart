import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

class CreateRental {
  final RentalRepository repository;

  CreateRental(this.repository);

  Future<Rental> call(Rental rental) async {
    return await repository.createRental(rental);
  }
}

