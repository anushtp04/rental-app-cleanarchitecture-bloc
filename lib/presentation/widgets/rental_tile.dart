import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/rental.dart';

class RentalTile extends StatelessWidget {
  final Rental rental;
  final VoidCallback? onTap;

  const RentalTile({
    super.key,
    required this.rental,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (rental.isCancelled) {
      statusColor = colorScheme.error;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel_outlined;
    } else {
      switch (rental.status) {
        case RentalStatus.ongoing:
          statusColor = Colors.green; // Distinct active color
          statusText = 'Active';
          statusIcon = Icons.directions_car_filled_rounded;
          break;
        case RentalStatus.upcoming:
          statusColor = Colors.orange;
          statusText = 'Upcoming';
          statusIcon = Icons.calendar_today_rounded;
          break;
        case RentalStatus.overdue:
          statusColor = Colors.red;
          statusText = 'Overdue';
          statusIcon = Icons.warning_amber_rounded;
          break;
        case RentalStatus.completed:
          statusColor = Colors.grey;
          statusText = 'Completed';
          statusIcon = Icons.check_circle_outline_rounded;
          break;
      }
    }


    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      color: theme.cardTheme.color,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap ?? () {
          context.pushNamed('rental-details', extra: rental);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rental.vehicleNumber} • ${rental.model}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rental.rentToPerson,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if(rental.isCommissionBased && !rental.isCancelled) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'C',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '₹${rental.totalAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: rental.isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
                              color: rental.isCancelled ? colorScheme.error : colorScheme.primary,
                            ),
                          ),
                          if (rental.isCancelled)
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                '₹${rental.cancellationAmount?.toStringAsFixed(0) ?? 0}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      context,
                      'From',
                      rental.rentFromDate,
                      Icons.arrow_forward_rounded,
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildDateInfo(
                      context,
                      'To',
                      rental.rentToDate,
                      Icons.arrow_back_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    String label,
    DateTime date,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
            Text(
              DateFormat('MMM dd, HH:mm').format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
