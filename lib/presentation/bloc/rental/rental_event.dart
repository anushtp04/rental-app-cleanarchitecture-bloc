part of 'rental_bloc.dart';

abstract class RentalEvent extends Equatable {
  const RentalEvent();

  @override
  List<Object> get props => [];
}

class LoadRentals extends RentalEvent {}

class AddRental extends RentalEvent {
  final Rental rental;

  const AddRental(this.rental);

  @override
  List<Object> get props => [rental];
}

class UpdateRentalEvent extends RentalEvent {
  final Rental rental;

  const UpdateRentalEvent(this.rental);

  @override
  List<Object> get props => [rental];
}

class DeleteRentalEvent extends RentalEvent {
  final String id;

  const DeleteRentalEvent(this.id);

  @override
  List<Object> get props => [id];
}

class FilterRentalsEvent extends RentalEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? vehicleNumber;
  final String? ownerName;

  const FilterRentalsEvent({
    this.fromDate,
    this.toDate,
    this.vehicleNumber,
    this.ownerName,
  });

  @override
  List<Object> get props => [fromDate ?? '', toDate ?? '', vehicleNumber ?? '', ownerName ?? ''];
}

class ClearFilters extends RentalEvent {}

