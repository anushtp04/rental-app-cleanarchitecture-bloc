import 'package:equatable/equatable.dart';

enum TransmissionType {
  manual,
  automatic,
}

class Car extends Equatable {
  final String id;
  final String vehicleNumber;
  final String make;
  final String model;
  final int year;
  final String color;
  final TransmissionType transmission;
  final String ownerName;
  final String ownerPhoneNumber;
  final String? imagePath;
  final double pricePerDay;

  const Car({
    required this.id,
    required this.vehicleNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.transmission,
    required this.ownerName,
    required this.ownerPhoneNumber,
    this.imagePath,
    required this.pricePerDay,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleNumber,
        make,
        model,
        year,
        color,
        transmission,
        ownerName,
        ownerPhoneNumber,
        imagePath,
        pricePerDay,
      ];
}
