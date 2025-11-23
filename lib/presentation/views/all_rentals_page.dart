import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/rental.dart';
import '../bloc/rental/rental_bloc.dart';
import '../widgets/rental_tile.dart';

class AllRentalsPage extends StatefulWidget {
  const AllRentalsPage({super.key});

  @override
  State<AllRentalsPage> createState() => _AllRentalsPageState();
}

class _AllRentalsPageState extends State<AllRentalsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  DateTime? _dateFilterStart;
  DateTime? _dateFilterEnd;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Rental> _filterRentals(List<Rental> rentals) {
    final filtered = rentals.where((rental) {
      // Search filter
      final query = _searchController.text.toLowerCase();
      final matchesSearch = rental.vehicleNumber.toLowerCase().contains(query) ||
          rental.rentToPerson.toLowerCase().contains(query) ||
          rental.model.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      // Category filter
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Active' && rental.status != RentalStatus.ongoing) return false;
        if (_selectedFilter == 'Completed' && rental.status != RentalStatus.completed) return false;
        if (_selectedFilter == 'Upcoming' && rental.status != RentalStatus.upcoming) return false;
      }

      // Date range filter
      if (_dateFilterStart != null && _dateFilterEnd != null) {
        final rentalStart = rental.rentFromDate;
        final rentalEnd = rental.rentToDate;
        
        final overlaps = rentalStart.isBefore(_dateFilterEnd!) && rentalEnd.isAfter(_dateFilterStart!);
        if (!overlaps) return false;
      }

      return true;
    }).toList();
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  Future<void> _showDateFilterModal() async {
    DateTime? tempStart = _dateFilterStart;
    DateTime? tempEnd = _dateFilterEnd;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempStart = null;
                            tempEnd = null;
                          });
                        },
                        child: const Text('Clear'),
                      ),
                      const Text(
                        'Filter by Date Range',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _dateFilterStart = tempStart;
                            _dateFilterEnd = tempEnd;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: tempStart ?? DateTime.now(),
                      rangeStartDay: tempStart,
                      rangeEndDay: tempEnd,
                      rangeSelectionMode: RangeSelectionMode.enforced,
                      onRangeSelected: (start, end, focusedDay) {
                        setModalState(() {
                          tempStart = start;
                          tempEnd = end;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        rangeStartDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            Text('Are you sure you want to cancel this rental?'),
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
                actualReturnDate: rental.actualReturnDate,
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

  Future<void> _showDeleteDialog(BuildContext context, Rental rental) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rental'),
        content: const Text('Are you sure you want to delete this rental? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<RentalBloc>().add(DeleteRentalEvent(rental.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rentals'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by vehicle number, renter, or model...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed'),
                      const SizedBox(width: 8),
                      // Date Filter Button
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(_dateFilterStart != null && _dateFilterEnd != null
                                ? 'Date Range'
                                : 'Filter by Date'),
                          ],
                        ),
                        selected: _dateFilterStart != null && _dateFilterEnd != null,
                        onSelected: (selected) => _showDateFilterModal(),
                      ),
                      if (_dateFilterStart != null && _dateFilterEnd != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _dateFilterStart = null;
                              _dateFilterEnd = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Rentals List
          Expanded(
            child: BlocBuilder<RentalBloc, RentalState>(
              builder: (context, state) {
                if (state is RentalLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RentalLoaded) {
                  final filteredRentals = _filterRentals(state.rentals);

                  if (filteredRentals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No rentals found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Categorize rentals
                  final activeRentals = filteredRentals
                      .where((r) => r.status == RentalStatus.ongoing && !r.isCancelled)
                      .toList();
                  final upcomingRentals = filteredRentals
                      .where((r) => r.status == RentalStatus.upcoming && !r.isCancelled)
                      .toList();
                  final cancelledRentals = filteredRentals
                      .where((r) => r.isCancelled)
                      .toList();
                  final completedRentals = filteredRentals
                      .where((r) => r.status == RentalStatus.completed && !r.isCancelled)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Active Rentals
                      if (activeRentals.isNotEmpty) ...[
                        _buildSectionHeader('Active', activeRentals.length, Colors.green),
                        const SizedBox(height: 12),
                        ...activeRentals.map((rental) => _buildRentalCard(context, rental)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Upcoming Rentals
                      if (upcomingRentals.isNotEmpty) ...[
                        _buildSectionHeader('Upcoming', upcomingRentals.length, Colors.orange),
                        const SizedBox(height: 12),
                        ...upcomingRentals.map((rental) => _buildRentalCard(context, rental)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Cancelled Rentals
                      if (cancelledRentals.isNotEmpty) ...[
                        _buildSectionHeader('Cancelled', cancelledRentals.length, Colors.red),
                        const SizedBox(height: 12),
                        ...cancelledRentals.map((rental) => _buildRentalCard(context, rental)),
                        const SizedBox(height: 24),
                      ],
                      
                      // Completed Rentals
                      if (completedRentals.isNotEmpty) ...[
                        _buildSectionHeader('Completed', completedRentals.length, Colors.grey),
                        const SizedBox(height: 12),
                        ...completedRentals.map((rental) => _buildRentalCard(context, rental)),
                        const SizedBox(height: 24),
                      ],
                    ],
                  );
                } else if (state is RentalError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  Widget _buildRentalCard(BuildContext context, Rental rental) {
    final canCancel = rental.status == RentalStatus.ongoing && 
                      !rental.isCancelled && 
                      DateTime.now().isBefore(rental.rentToDate);
    final canDelete = rental.status == RentalStatus.upcoming && !rental.isCancelled;

    // If can't cancel or delete, show regular card
    if (!canCancel && !canDelete) {
      return _buildCardContent(context, rental);
    }

    // Use Dismissible for swipe actions
    return Dismissible(
      key: Key(rental.id),
      direction: canCancel && canDelete 
          ? DismissDirection.horizontal 
          : (canCancel ? DismissDirection.endToStart : DismissDirection.startToEnd),
      background: Container(
        color: canDelete ? Colors.red : Colors.orange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          canDelete ? Icons.delete : Icons.cancel,
          color: Colors.white,
          size: 32,
        ),
      ),
      secondaryBackground: canCancel
          ? Container(
              color: Colors.orange,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.cancel, color: Colors.white, size: 32),
            )
          : null,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && canDelete) {
          // Swipe right - Delete
          return await _confirmDismissDelete(context, rental);
        } else if (direction == DismissDirection.endToStart && canCancel) {
          // Swipe left - Cancel
          await _showCancelDialog(context, rental);
          return false; // Don't dismiss, dialog handles it
        }
        return false;
      },
      child: _buildCardContent(context, rental),
    );
  }

  Future<bool> _confirmDismissDelete(BuildContext context, Rental rental) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rental'),
        content: const Text('Are you sure you want to delete this rental?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<RentalBloc>().add(DeleteRentalEvent(rental.id));
      return true;
    }
    return false;
  }

  Widget _buildCardContent(BuildContext context, Rental rental) {
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${rental.vehicleNumber} - ${rental.model}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (rental.isCancelled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CANCELLED',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMM dd').format(rental.rentFromDate)} - ${DateFormat('MMM dd').format(rental.rentToDate)}',
            ),
            if (rental.isCancelled && rental.cancellationAmount != null)
              Text(
                'Cancellation: ₹${rental.cancellationAmount!.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${rental.isCancelled && rental.cancellationAmount != null ? rental.cancellationAmount!.toStringAsFixed(0) : rental.totalAmount.toStringAsFixed(0)}',
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
                _buildStatusBadge(rental),
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

  Widget _buildStatusBadge(Rental rental) {
    Color color;
    String text;

    if (rental.isCancelled) {
      color = Colors.red;
      text = 'Cancelled';
    } else {
      switch (rental.status) {
        case RentalStatus.ongoing:
          color = Colors.green;
          text = 'Active';
          break;
        case RentalStatus.upcoming:
          color = Colors.orange;
          text = 'Upcoming';
          break;
        case RentalStatus.completed:
          color = Colors.grey;
          text = 'Completed';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
