import 'package:hive/hive.dart';
import '../../domain/entities/car.dart';

part 'car_model.g.dart';

@HiveType(typeId: 1)
class CarModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String vehicleNumber;
  
  @HiveField(2)
  final String make;
  
  @HiveField(3)
  final String model;
  
  @HiveField(4)
  final int year;
  
  @HiveField(5)
  final String color;
  
  @HiveField(6)
  final String transmission; // Store as string
  
  @HiveField(7)
  final String ownerName;
  
  @HiveField(8)
  final String ownerPhoneNumber;
  
  @HiveField(9)
  final String? imagePath;
  
  @HiveField(10)
  final double pricePerDay;

  CarModel({
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

  factory CarModel.fromEntity(Car car) {
    return CarModel(
      id: car.id,
      vehicleNumber: car.vehicleNumber,
      make: car.make,
      model: car.model,
      year: car.year,
      color: car.color,
      transmission: car.transmission.name, // Convert enum to string
      ownerName: car.ownerName,
      ownerPhoneNumber: car.ownerPhoneNumber,
      imagePath: car.imagePath,
      pricePerDay: car.pricePerDay,
    );
  }

  Car toEntity() {
    return Car(
      id: id,
      vehicleNumber: vehicleNumber,
      make: make,
      model: model,
      year: year,
      color: color,
      transmission: TransmissionType.values.firstWhere(
        (e) => e.name == transmission,
        orElse: () => TransmissionType.manual,
      ),
      ownerName: ownerName,
      ownerPhoneNumber: ownerPhoneNumber,
      imagePath: imagePath,
      pricePerDay: pricePerDay,
    );
  }
}
