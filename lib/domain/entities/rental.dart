import 'package:equatable/equatable.dart';

enum RentalStatus {
  upcoming,
  ongoing,
  completed,
}

class Rental extends Equatable {
  final String id;
  final String? carId; // Link to Car entity
  final String vehicleNumber;
  final String model;
  final int year;
  final String rentToPerson; // Changed from ownerName
  final String? contactNumber; // New optional field
  final String? email; // New optional field
  final String? address; // New optional field
  final String? notes; // New optional field
  final DateTime rentFromDate;
  final DateTime rentToDate;
  final double totalAmount;
  final String? imagePath;
  final String? documentPath;
  final DateTime createdAt;
  final DateTime? actualReturnDate;
  final bool isReturnApproved;
  final bool isCommissionBased;
  final bool isCancelled;
  final double? cancellationAmount;

  const Rental({
    required this.id,
    this.carId,
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

  RentalStatus get status {
    // Check if cancelled first
    if (isCancelled) {
      return RentalStatus.completed; // Treat as completed but with cancelled flag
    }
    
    // Only return completed if explicitly approved
    if (isReturnApproved) {
      return RentalStatus.completed;
    }
    
    final now = DateTime.now();
    // Don't auto-complete - rentals remain ongoing/upcoming until explicitly approved
    if (rentFromDate.isAfter(now)) {
      return RentalStatus.upcoming;
    } else {
      // If rentFromDate has passed, it's ongoing (even if past due date)
      // It will only be completed when isReturnApproved is true
      return RentalStatus.ongoing;
    }
  }

  Rental copyWith({
    String? id,
    String? carId,
    String? vehicleNumber,
    String? model,
    int? year,
    String? rentToPerson,
    String? contactNumber,
    String? email,
    String? address,
    String? notes,
    DateTime? rentFromDate,
    DateTime? rentToDate,
    double? totalAmount,
    String? imagePath,
    String? documentPath,
    DateTime? createdAt,
    DateTime? actualReturnDate,
    bool? isReturnApproved,
  }) {
    return Rental(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      model: model ?? this.model,
      year: year ?? this.year,
      rentToPerson: rentToPerson ?? this.rentToPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rentFromDate: rentFromDate ?? this.rentFromDate,
      rentToDate: rentToDate ?? this.rentToDate,
      totalAmount: totalAmount ?? this.totalAmount,
      imagePath: imagePath ?? this.imagePath,
      documentPath: documentPath ?? this.documentPath,
      createdAt: createdAt ?? this.createdAt,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      isReturnApproved: isReturnApproved ?? this.isReturnApproved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        carId,
        vehicleNumber,
        model,
        year,
        rentToPerson,
        contactNumber,
        email,
        address,
        notes,
        rentFromDate,
        rentToDate,
        totalAmount,
        imagePath,
        documentPath,
        documentPath,
        createdAt,
        actualReturnDate,
        isReturnApproved,
      ];
}

