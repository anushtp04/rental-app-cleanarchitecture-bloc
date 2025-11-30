import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/rental.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/rental/rental_bloc.dart';
import '../widgets/car_image_widget.dart';

class CarDetailsPage extends StatelessWidget {
  final Car car;

  const CarDetailsPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${car.make} ${car.model}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/add-car', extra: car),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            CarImageWidget(
              imagePath: car.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '${car.make} ${car.model}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.vehicleNumber,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.currency_rupee, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${car.pricePerDay.toStringAsFixed(0)} per day',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Details Section
                  const Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_today, 'Year', car.year.toString()),
                  _buildDetailRow(Icons.palette, 'Color', car.color),
                  _buildDetailRow(Icons.settings, 'Transmission', 
                    car.transmission == TransmissionType.manual ? 'Manual' : 'Automatic'),
                  
                  const SizedBox(height: 32),
                  
                  // Owner Details Section
                  const Text(
                    'Owner Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person, 'Owner Name', car.ownerName),
                  _buildDetailRow(Icons.phone, 'Contact', car.ownerPhoneNumber),
                  
                  const SizedBox(height: 32),
                  
                  // Active Rentals Section
                  BlocBuilder<RentalBloc, RentalState>(
                    builder: (context, state) {
                      if (state is RentalLoaded) {
                        final activeRentals = state.rentals.where((rental) {
                          return rental.carId == car.id &&
                                 (rental.status == RentalStatus.ongoing ||
                                  rental.status == RentalStatus.overdue) &&
                                 !rental.isCancelled;
                        }).toList();

                        if (activeRentals.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Rentals',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...activeRentals.map((rental) => _buildActiveRentalCard(context, rental)),
                              const SizedBox(height: 32),
                            ],
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        'Delete Vehicle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${car.make} ${car.model}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<CarBloc>().add(DeleteCarEvent(car.id));
      context.pop(); // Go back to previous screen
    }
  }

  Widget _buildActiveRentalCard(BuildContext context, Rental rental) {
    final isOverdue = rental.status == RentalStatus.overdue;
    final statusColor = isOverdue ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOverdue ? Icons.warning_amber_rounded : Icons.directions_car_filled,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rental.rentToPerson,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOverdue ? 'OVERDUE' : 'ACTIVE',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${DateFormat('MMM dd').format(rental.rentFromDate)} - ${DateFormat('MMM dd').format(rental.rentToDate)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Text(
                '₹${rental.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, rental),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancel Rental'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context, Rental rental) async {
    final amountController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Rental'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this rental?'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              final updatedRental = Rental(
                id: rental.id,
                carId: rental.carId,
                vehicleNumber: rental.vehicleNumber,
                model: rental.model,
                year: rental.year,
                rentToPerson: rental.rentToPerson,
                contactNumber: rental.contactNumber,
                address: rental.address,
                rentFromDate: rental.rentFromDate,
                rentToDate: rental.rentToDate,
                totalAmount: rental.totalAmount,
                imagePath: rental.imagePath,
                documentPath: rental.documentPath,
                createdAt: rental.createdAt,
                actualReturnDate: DateTime.now(),
                isReturnApproved: rental.isReturnApproved,
                isCommissionBased: rental.isCommissionBased,
                isCancelled: true,
                cancellationAmount: amount,
              );
              context.read<RentalBloc>().add(UpdateRentalEvent(updatedRental));
              Navigator.pop(dialogContext);
              // Reload rentals to update UI
              context.read<RentalBloc>().add(LoadRentals());
            },
            child: const Text('Cancel Rental'),
          ),
        ],
      ),
    );
  }
}
