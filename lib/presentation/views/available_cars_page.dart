import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/rental.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/rental/rental_bloc.dart';
import '../../core/utils/image_helper.dart';

class AvailableCarsPage extends StatefulWidget {
  const AvailableCarsPage({super.key});

  @override
  State<AvailableCarsPage> createState() => _AvailableCarsPageState();
}

class _AvailableCarsPageState extends State<AvailableCarsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(LoadCars());
    context.read<RentalBloc>().add(LoadRentals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Cars'),
        elevation: 0,
      ),
      body: BlocBuilder<CarBloc, CarState>(
        builder: (context, carState) {
          if (carState is CarLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (carState is CarLoaded) {
            if (carState.cars.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_outlined, size: 64,
                        color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No cars available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.push('/add-car'),
                      child: const Text('Add Your First Car'),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<RentalBloc, RentalState>(
              builder: (context, rentalState) {
                Set<String> rentedCarIds = {};
                if (rentalState is RentalLoaded) {
                  rentedCarIds = rentalState.rentals
                      .where((r) =>
                  (r.status == RentalStatus.ongoing || r.status == RentalStatus.overdue) && !r.isCancelled)
                      .map((r) => r.carId)
                      .whereType<String>()
                      .toSet();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: carState.cars.length,
                  itemBuilder: (context, index) {
                    final car = carState.cars[index];
                    final isRented = rentedCarIds.contains(car.id);
                    return _buildModernCarCard(
                        context, car, isRented: isRented);
                  },
                );
              },
            );
          } else if (carState is CarError) {
            return Center(child: Text('Error: ${carState.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-car'),
        child: const Icon(Icons.add),
      ),
    );
  }


  Widget _buildModernCarCard(BuildContext context, Car car,
      {bool isRented = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/add-car', extra: car),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                image: car.imagePath != null
                    ? DecorationImage(
                  image: FileImage(File(car.imagePath!)),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: Stack(
                children: [
                  if (car.imagePath == null)
                    Center(
                      child: Icon(Icons.directions_car, size: 48,
                          color: Colors.grey[400]),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isRented)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car, color: Colors.white,
                                size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Running',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Car Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.make} ${car.model}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.vehicleNumber,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.settings, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          car.transmission == TransmissionType.manual
                              ? 'Manual'
                              : 'Auto',
                          style: TextStyle(fontSize: 10, color: Colors
                              .grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${car.pricePerDay.toStringAsFixed(0)}/day',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => context.push('/add-car', extra: car),
                              child: const Icon(
                                  Icons.edit, size: 18, color: Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _confirmDelete(context, car),
                              child: const Icon(
                                  Icons.delete, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Car car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Car'),
            content: Text(
                'Are you sure you want to delete ${car.make} ${car.model}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                      'Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
    );

    if (confirm == true && mounted) {
      context.read<CarBloc>().add(DeleteCarEvent(car.id));
    }
  }
}

