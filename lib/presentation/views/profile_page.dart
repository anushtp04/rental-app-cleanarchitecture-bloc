import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/rental.dart';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../widgets/rental_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Completed', 'Upcoming'];
  DateTime? _dateFilterStart;
  DateTime? _dateFilterEnd;

  @override
  void initState() {
    super.initState();
    context.read<RentalBloc>().add(LoadRentals());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Rental> _filterRentals(List<Rental> rentals) {
    final filtered = rentals.where((rental) {
      // Search filter - search by vehicle number, renter name, and model
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
        
        // Check if rental overlaps with filter range
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
    DateTime focusedDay = _dateFilterStart ?? DateTime.now();
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
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _dateFilterStart = null;
                            _dateFilterEnd = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                      const Text(
                        'Filter by Date',
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
                      firstDay: DateTime.now().subtract(const Duration(days: 365 * 2)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) => isSameDay(tempStart, day),
                      rangeStartDay: tempStart,
                      rangeEndDay: tempEnd,
                      calendarFormat: CalendarFormat.month,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      onDaySelected: (selectedDay, newFocusedDay) {
                        setModalState(() {
                          if (!isSameDay(tempStart, selectedDay)) {
                            tempStart = selectedDay;
                            focusedDay = newFocusedDay;
                            tempEnd = null;
                          }
                        });
                      },
                      onRangeSelected: (start, end, newFocusedDay) {
                        setModalState(() {
                          tempStart = start;
                          tempEnd = end;
                          focusedDay = newFocusedDay;
                        });
                      },
                      onPageChanged: (newFocusedDay) {
                        focusedDay = newFocusedDay;
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeBloc>().state is ThemeLoaded &&
                      (context.watch<ThemeBloc>().state as ThemeLoaded).isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String userEmail = 'user@example.com';

              if (authState is AuthAuthenticated) {
                userEmail = authState.email;
              }
              
              return Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        userEmail,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<RentalBloc, RentalState>(
              builder: (context, state) {
                int activeRentals = 0;
                double totalRevenue = 0;
                double thisMonthRevenue = 0;
                double commissionRevenue = 0;

                if (state is RentalLoaded) {
                  activeRentals = state.rentals.where((r) => r.status == RentalStatus.ongoing && !r.isCancelled).length;
                  
                  // Calculate total revenue (use cancellation amount for cancelled rentals)
                  totalRevenue = state.rentals.fold(0, (sum, item) {
                    if (item.isCancelled && item.cancellationAmount != null) {
                      return sum + item.cancellationAmount!;
                    }else if(item.status == RentalStatus.completed ){
                    return sum + item.totalAmount;
                    }
                    return sum;
                  });
                  
                  // Calculate this month revenue
                  final now = DateTime.now();
                  final thisMonthStart = DateTime(now.year, now.month, 1);
                  final nextMonthStart = DateTime(now.year, now.month + 1, 1);
                  
                  thisMonthRevenue = state.rentals
                      .where((r) => 
                          r.createdAt.isAfter(thisMonthStart) && 
                          r.createdAt.isBefore(nextMonthStart))
                      .fold(0, (sum, item) {
                        if (item.isCancelled && item.cancellationAmount != null) {
                          return sum + item.cancellationAmount!;
                        }else if(item.status == RentalStatus.completed && !item.isCommissionBased) {
                          return sum + item.totalAmount;
                        }
                        return sum;
                      });
                  
                  // Calculate commission revenue (exclude cancelled)
                  commissionRevenue = state.rentals
                      .where((r) => r.isCommissionBased && !r.isCancelled)
                      .fold(0, (sum, item) => sum + item.totalAmount);
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'Active Rentals',
                            value: activeRentals.toString(),
                            icon: Icons.car_rental,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'Total Revenue',
                            value: '₹${totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.attach_money,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'This Month Revenue',
                            value: '₹${thisMonthRevenue.toStringAsFixed(0)}',
                            icon: Icons.calendar_month,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            title: 'Commission Revenue',
                            value: '₹${commissionRevenue.toStringAsFixed(0)}',
                            icon: Icons.percent,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
