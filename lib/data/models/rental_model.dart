import 'package:hive/hive.dart';
import '../../domain/entities/rental.dart';

part 'rental_model.g.dart';

@HiveType(typeId: 0)
class RentalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String vehicleNumber;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String rentToPerson;

  @HiveField(5)
  final String? contactNumber;

  @HiveField(6)
  final String? email;

  @HiveField(7)
  final String? address;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime rentFromDate;

  @HiveField(10)
  final DateTime rentToDate;

  @HiveField(11)
  final double totalAmount;

  @HiveField(12)
  final String? imagePath;

  @HiveField(13)
  final String? documentPath;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime? actualReturnDate;

  @HiveField(16)
  final bool isReturnApproved;

  @HiveField(17)
  final bool isCommissionBased;

  @HiveField(18)
  final bool isCancelled;

  @HiveField(19)
  final double? cancellationAmount;

  RentalModel({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.year,
    required this.rentToPerson,
    this.contactNumber,
    this.email,
    this.address,
    this.notes,
    required this.rentFromDate,
    required this.rentToDate,
    required this.totalAmount,
    this.imagePath,
    this.documentPath,
    required this.createdAt,
    this.actualReturnDate,
    this.isReturnApproved = false,
    this.isCommissionBased = false,
    this.isCancelled = false,
    this.cancellationAmount,
  });

  factory RentalModel.fromEntity(Rental rental) {
    return RentalModel(
      id: rental.id,
      vehicleNumber: rental.vehicleNumber,
      model: rental.model,
      year: rental.year,
      rentToPerson: rental.rentToPerson,
      contactNumber: rental.contactNumber,
      email: rental.email,
      address: rental.address,
      notes: rental.notes,
      rentFromDate: rental.rentFromDate,
      rentToDate: rental.rentToDate,
      totalAmount: rental.totalAmount,
      imagePath: rental.imagePath,
      documentPath: rental.documentPath,
      createdAt: rental.createdAt,
      actualReturnDate: rental.actualReturnDate,
      isReturnApproved: rental.isReturnApproved,
      isCommissionBased: rental.isCommissionBased,
      isCancelled: rental.isCancelled,
      cancellationAmount: rental.cancellationAmount,
    );
  }

  Rental toEntity() {
    return Rental(
      id: id,
      vehicleNumber: vehicleNumber,
      model: model,
      year: year,
      rentToPerson: rentToPerson,
      contactNumber: contactNumber,
      email: email,
      address: address,
      notes: notes,
      rentFromDate: rentFromDate,
      rentToDate: rentToDate,
      totalAmount: totalAmount,
      imagePath: imagePath,
      documentPath: documentPath,
      createdAt: createdAt,
      actualReturnDate: actualReturnDate,
      isReturnApproved: isReturnApproved,
      isCommissionBased: isCommissionBased,
      isCancelled: isCancelled,
      cancellationAmount: cancellationAmount,
    );
  }

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      rentToPerson: json['rentToPerson'] as String,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      rentFromDate: DateTime.parse(json['rentFromDate'] as String),
      rentToDate: DateTime.parse(json['rentToDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
      documentPath: json['documentPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actualReturnDate: json['actualReturnDate'] != null ? DateTime.parse(json['actualReturnDate'] as String) : null,
      isReturnApproved: json['isReturnApproved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'model': model,
      'year': year,
      'rentToPerson': rentToPerson,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'rentFromDate': rentFromDate.toIso8601String(),
      'rentToDate': rentToDate.toIso8601String(),
      'totalAmount': totalAmount,
      'imagePath': imagePath,
      'documentPath': documentPath,
      'createdAt': createdAt.toIso8601String(),
      'actualReturnDate': actualReturnDate?.toIso8601String(),
      'isReturnApproved': isReturnApproved,
    };
  }
}
