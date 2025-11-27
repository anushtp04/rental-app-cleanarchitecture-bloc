import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/rental.dart';
import '../../../domain/usecases/get_all_rentals.dart';
import '../../../domain/usecases/create_rental.dart';
import '../../../domain/usecases/update_rental.dart';
import '../../../domain/usecases/delete_rental.dart';
import '../../../domain/usecases/filter_rentals.dart';

part 'rental_event.dart';
part 'rental_state.dart';

class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final GetAllRentals getAllRentals;
  final CreateRental createRental;
  final UpdateRental updateRental;
  final DeleteRental deleteRental;
  final FilterRentals filterRentals;



  RentalBloc({
    required this.getAllRentals,
    required this.createRental,
    required this.updateRental,
    required this.deleteRental,
    required this.filterRentals,
  }) : super(RentalInitial()) {
    on<LoadRentals>(_onLoadRentals);
    on<AddRental>(_onAddRental);
    on<UpdateRentalEvent>(_onUpdateRental);
    on<DeleteRentalEvent>(_onDeleteRental);
    on<FilterRentalsEvent>(_onFilterRentals);
    on<ClearFilters>(_onClearFilters);

  }



  Future<void> _onLoadRentals(LoadRentals event, Emitter<RentalState> emit) async {
    emit(RentalLoading());
    try {
      final rentals = await getAllRentals();
      emit(RentalLoaded(rentals: rentals));

    } catch (e) {
      emit(RentalError(message: e.toString()));
    }
  }

  Future<void> _onAddRental(AddRental event, Emitter<RentalState> emit) async {
    try {
      await createRental(event.rental);
      final rentals = await getAllRentals();
      emit(RentalLoaded(rentals: rentals));
    } catch (e) {
      emit(RentalError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRental(UpdateRentalEvent event, Emitter<RentalState> emit) async {
    try {
      await updateRental(event.rental);
      final rentals = await getAllRentals();
      emit(RentalLoaded(rentals: rentals));
    } catch (e) {
      emit(RentalError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRental(DeleteRentalEvent event, Emitter<RentalState> emit) async {
    try {
      await deleteRental(event.id);
      final rentals = await getAllRentals();
      emit(RentalLoaded(rentals: rentals));
    } catch (e) {
      emit(RentalError(message: e.toString()));
    }
  }

  Future<void> _onFilterRentals(FilterRentalsEvent event, Emitter<RentalState> emit) async {
    try {
      final filteredRentals = await filterRentals(
        fromDate: event.fromDate,
        toDate: event.toDate,
        vehicleNumber: event.vehicleNumber,
        ownerName: event.ownerName,
      );
      emit(RentalLoaded(
        rentals: filteredRentals,
        isFiltered: true,
      ));
    } catch (e) {
      emit(RentalError(message: e.toString()));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<RentalState> emit) async {
    add(LoadRentals());
  }
}

