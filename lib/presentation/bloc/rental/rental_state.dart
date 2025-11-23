part of 'rental_bloc.dart';

abstract class RentalState extends Equatable {
  const RentalState();

  @override
  List<Object> get props => [];
}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalLoaded extends RentalState {
  final List<Rental> rentals;
  final bool isFiltered;

  const RentalLoaded({
    required this.rentals,
    this.isFiltered = false,
  });

  @override
  List<Object> get props => [rentals, isFiltered];
}

class RentalError extends RentalState {
  final String message;

  const RentalError({required this.message});

  @override
  List<Object> get props => [message];
}

