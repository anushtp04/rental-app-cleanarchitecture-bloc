import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

class UpdateRental {
  final RentalRepository repository;

  UpdateRental(this.repository);

  Future<Rental> call(Rental rental) async {
    return await repository.updateRental(rental);
  }
}

