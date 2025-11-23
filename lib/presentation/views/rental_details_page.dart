import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/rental.dart';
import '../bloc/rental/rental_bloc.dart';
import '../widgets/document_preview_page.dart';

class RentalDetailsPage extends StatefulWidget {
  final Rental rental;

  const RentalDetailsPage({super.key, required this.rental});

  @override
  State<RentalDetailsPage> createState() => _RentalDetailsPageState();
}

class _RentalDetailsPageState extends State<RentalDetailsPage> {
  late Rental rental;

  @override
  void initState() {
    super.initState();
    rental = widget.rental;
    // Listen to rental updates
    context.read<RentalBloc>().stream.listen((state) {
      if (state is RentalLoaded) {
        final updatedRental = state.rentals.firstWhere(
          (r) => r.id == rental.id,
          orElse: () => rental,
        );
        if (updatedRental.id == rental.id && updatedRental != rental) {
          setState(() {
            rental = updatedRental;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    // Check if cancelled first
    if (rental.isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Cancelled';
    } else {
      switch (rental.status) {
        case RentalStatus.ongoing:
          statusColor = Colors.green;
          statusIcon = Icons.play_circle_filled;
          statusText = 'Active';
          break;
        case RentalStatus.upcoming:
          statusColor = Colors.orange;
          statusIcon = Icons.schedule;
          statusText = 'Upcoming';
          break;
        case RentalStatus.completed:
          statusColor = Colors.grey;
          statusIcon = Icons.check_circle;
          statusText = 'Completed';
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            elevation: 0,
            actions: rental.status != RentalStatus.completed
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await context.pushNamed('add-rental', extra: rental);
                        // Reload rentals after returning from edit page
                        if (mounted) {
                          context.read<RentalBloc>().add(LoadRentals());
                        }
                      },
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (rental.imagePath != null)
                    Image.file(
                      File(rental.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_car, size: 80),
                        );
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.directions_car, size: 80, color: Colors.white),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Vehicle info at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rental.vehicleNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${rental.model} (${rental.year})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: rental.isCancelled 
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          rental.isCancelled 
                              ? (rental.isCommissionBased 
                                  ? 'Cancellation Amount (Commission Based)' 
                                  : 'Cancellation Amount')
                              : (rental.isCommissionBased 
                                  ? 'Total Amount (Commission Based)' 
                                  : 'Total Amount'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${rental.isCancelled && rental.cancellationAmount != null ? rental.cancellationAmount!.toStringAsFixed(0) : rental.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (rental.isCancelled && rental.cancellationAmount != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Original: ₹${rental.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Rental Period Card
                  _buildSectionCard(
                    context,
                    title: 'Rental Period',
                    icon: Icons.calendar_month,
                    color: Colors.blue,
                    children: [
                      _buildTimelineItem(
                        context,
                        icon: Icons.flight_takeoff,
                        label: 'Pick-up',
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(rental.rentFromDate),
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineItem(
                        context,
                        icon: Icons.flight_land,
                        label: 'Return',
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(rental.rentToDate),
                        color: Colors.orange,
                      ),
                      if (rental.actualReturnDate != null) ...[
                        const SizedBox(height: 16),
                        _buildTimelineItem(
                          context,
                          icon: Icons.check_circle,
                          label: 'Actual Return',
                          value: DateFormat('dd MMM yyyy, hh:mm a').format(rental.actualReturnDate!),
                          color: rental.actualReturnDate!.isAfter(rental.rentToDate)
                              ? Colors.red
                              : Colors.green,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Renter Information Card
                  _buildSectionCard(
                    context,
                    title: 'Renter Information',
                    icon: Icons.person,
                    color: Colors.purple,
                    children: [
                      _buildInfoRow(Icons.person_outline, 'Name', rental.rentToPerson),
                      if (rental.contactNumber != null && rental.contactNumber!.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildInfoRow(Icons.phone_outlined, 'Phone', rental.contactNumber!),
                      ],
                      if (rental.address != null && rental.address!.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildInfoRow(Icons.location_on_outlined, 'Address', rental.address!),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Document Card
                  if (rental.documentPath != null)
                    _buildSectionCard(
                      context,
                      title: 'Document',
                      icon: Icons.description,
                      color: Colors.teal,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DocumentPreviewPage(
                                  filePath: rental.documentPath!,
                                  fileName: path.basename(rental.documentPath!),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(_getDocumentIcon(rental.documentPath!), color: Colors.teal),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    path.basename(rental.documentPath!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Metadata Card
                  _buildSectionCard(
                    context,
                    title: 'Additional Info',
                    icon: Icons.info_outline,
                    color: Colors.grey,
                    children: [
                      _buildInfoRow(
                        Icons.access_time,
                        'Created',
                        DateFormat('dd MMM yyyy, hh:mm a').format(rental.createdAt),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Complete Rental Button
                  if (rental.status != RentalStatus.completed && !rental.isCancelled)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: DateTime.now().isAfter(rental.rentToDate)
                            ? () => _showCompleteRentalDialog(context)
                            : null,
                        icon: const Icon(Icons.check_circle_outline, size: 24),
                        label: Text('Complete Rental',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DateTime.now().isAfter(rental.rentToDate)
                              ? Colors.green
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _showCompleteRentalDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    // Default to rentToDate if not yet passed, otherwise use current time
    if (DateTime.now().isAfter(rental.rentToDate)) {
      selectedDate = DateTime.now();
    } else {
      selectedDate = rental.rentToDate;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Calculate amount dynamically based on selectedDate
          double finalAmount = rental.totalAmount;
          double? overtimeCharge;
          int? overtimeHours;
          
          if (selectedDate.isAfter(rental.rentToDate)) {
            // Calculate overtime in hours
            final overtimeDuration = selectedDate.difference(rental.rentToDate);
            overtimeHours = overtimeDuration.inHours + (overtimeDuration.inMinutes % 60 > 0 ? 1 : 0);
            
            // Calculate daily rate (approximate from total amount and days)
            final rentalDuration = rental.rentToDate.difference(rental.rentFromDate);
            final rentalDays = rentalDuration.inDays + (rentalDuration.inHours % 24 > 0 ? 1 : 0);
            final dailyRate = rentalDays > 0 ? rental.totalAmount / rentalDays : rental.totalAmount;
            
            // Calculate overtime charge (proportional to daily rate)
            overtimeCharge = (dailyRate / 24) * overtimeHours;
            finalAmount = rental.totalAmount + overtimeCharge;
          }
          
          return AlertDialog(
            title: const Text('Complete Rental'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please confirm the return date and time:'),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: rental.rentFromDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount breakdown
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Original Amount:'),
                            Text('₹${rental.totalAmount.toStringAsFixed(0)}'),
                          ],
                        ),
                        if (overtimeCharge != null && overtimeCharge! > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overtime Charge (${overtimeHours}h):',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                              Text(
                                '+₹${overtimeCharge!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹${finalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
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
                    totalAmount: finalAmount,
                    imagePath: rental.imagePath,
                    documentPath: rental.documentPath,
                    createdAt: rental.createdAt,
                    actualReturnDate: selectedDate,
                    isReturnApproved: true,
                    isCommissionBased: rental.isCommissionBased,
                  );
                  context.read<RentalBloc>().add(UpdateRentalEvent(updatedRental));
                  Navigator.pop(context);
                  // Reload rentals and pop the details page
                  context.read<RentalBloc>().add(LoadRentals());
                  Navigator.pop(context);
                },
                child: const Text('Complete'),
              ),
            ],
          );
        },
      ),
    );
  }
}
