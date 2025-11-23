import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/rental.dart';

class RentalTile extends StatelessWidget {
  final Rental rental;

  const RentalTile({
    super.key,
    required this.rental,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    // Check if cancelled first
    if (rental.isCancelled) {
      statusColor = Colors.red;
      statusText = 'Cancelled';
    } else {
      switch (rental.status) {
        case RentalStatus.ongoing:
          statusColor = Colors.green;
          statusText = 'Active';
          break;
        case RentalStatus.upcoming:
          statusColor = Colors.orange;
          statusText = 'Upcoming';
          break;
        case RentalStatus.completed:
          statusColor = Colors.grey;
          statusText = 'Completed';
          break;
      }
    }

    // Use cancellation amount if cancelled, otherwise total amount
    final displayAmount = rental.isCancelled && rental.cancellationAmount != null
        ? rental.cancellationAmount!
        : rental.totalAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.directions_car, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          '${rental.vehicleNumber} - ${rental.model}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd').format(rental.rentFromDate)} - ${DateFormat('MMM dd').format(rental.rentToDate)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${displayAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rental.isCancelled ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rental.isCommissionBased && !rental.isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          context.pushNamed('rental-details', extra: rental);
        },
      ),
    );
  }
}
