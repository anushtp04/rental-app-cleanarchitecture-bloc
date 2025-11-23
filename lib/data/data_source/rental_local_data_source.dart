import 'package:hive_flutter/hive_flutter.dart';
import '../models/rental_model.dart';

abstract class RentalLocalDataSource {
  Future<List<RentalModel>> getAllRentals();
  Future<RentalModel> getRentalById(String id);
  Future<void> cacheRental(RentalModel rental);
  Future<void> updateCachedRental(RentalModel rental);
  Future<void> deleteRental(String id);
  Future<void> deleteAllRentals();
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  });
}

class RentalLocalDataSourceImpl implements RentalLocalDataSource {
  final Box<RentalModel> rentalBox;

  RentalLocalDataSourceImpl(this.rentalBox);

  @override
  Future<List<RentalModel>> getAllRentals() async {
    return rentalBox.values.toList();
  }

  @override
  Future<RentalModel> getRentalById(String id) async {
    final rental = rentalBox.get(id);
    if (rental != null) {
      return rental;
    } else {
      throw Exception('Rental not found');
    }
  }

  @override
  Future<void> cacheRental(RentalModel rental) async {
    await rentalBox.put(rental.id, rental);
  }

  @override
  Future<void> updateCachedRental(RentalModel rental) async {
    await rentalBox.put(rental.id, rental);
  }

  @override
  Future<void> deleteRental(String id) async {
    await rentalBox.delete(id);
  }

  @override
  Future<void> deleteAllRentals() async {
    await rentalBox.clear();
  }

  @override
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  }) async {
    List<RentalModel> rentals = rentalBox.values.toList();

    if (fromDate != null) {
      rentals = rentals.where((rental) {
        return rental.rentFromDate.isAfter(fromDate) ||
            rental.rentFromDate.isAtSameMomentAs(fromDate);
      }).toList();
    }

    if (toDate != null) {
      rentals = rentals.where((rental) {
        return rental.rentToDate.isBefore(toDate) ||
            rental.rentToDate.isAtSameMomentAs(toDate);
      }).toList();
    }

    if (vehicleNumber != null && vehicleNumber.isNotEmpty) {
      rentals = rentals.where((rental) {
        return rental.vehicleNumber
            .toLowerCase()
            .contains(vehicleNumber.toLowerCase());
      }).toList();
    }

    if (ownerName != null && ownerName.isNotEmpty) {
      rentals = rentals.where((rental) {
        return rental.rentToPerson
            .toLowerCase()
            .contains(ownerName.toLowerCase());
      }).toList();
    }

    return rentals;
  }
}

