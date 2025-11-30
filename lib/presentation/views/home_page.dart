import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/rental.dart';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/car/car_bloc.dart';
import '../widgets/rental_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<RentalBloc>().add(LoadRentals());
    context.read<CarBloc>().add(LoadCars());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for modern feel
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RentalBloc>().add(LoadRentals());
          context.read<CarBloc>().add(LoadCars());
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 100,
              toolbarHeight: 64,
              backgroundColor: Colors.grey[50],
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                centerTitle: false,
                title: const SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSection(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildOvertimeRentalsSection(context),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pushNamed('all-rentals'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRecentRentalsList(context),
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              int carCount = 0;
              if (state is CarLoaded) {
                carCount = state.cars.length;
              }
              return _buildStatCard(
                context,
                title: 'Total Cars',
                value: carCount.toString(),
                icon: Icons.directions_car_filled,
                color: Colors.blue,
                onTap: () => context.pushNamed('available-cars'),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<RentalBloc, RentalState>(
            builder: (context, state) {
              int activeRentals = 0;
              if (state is RentalLoaded) {
                activeRentals = state.rentals
                    .where((r) => (r.status == RentalStatus.ongoing || r.status == RentalStatus.overdue) && !r.isCancelled)
                    .length;
              }
              return _buildStatCard(
                context,
                title: 'Active Rentals',
                value: activeRentals.toString(),
                icon: Icons.key,
                color: Colors.orange,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Add New Car',
                icon: Icons.add,
                color: Colors.black,
                onTap: () => context.push('/add-car'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'New Rental',
                icon: Icons.receipt_long,
                color: Colors.green,
                onTap: () => context.pushNamed('add-rental'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimeRentalsSection(BuildContext context) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        if (state is RentalLoaded) {
          final overdueRentals = state.rentals.where((rental) {
            return !rental.isCancelled && rental.status == RentalStatus.overdue;
          }).toList();

          if (overdueRentals.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_rounded, color: Colors.red[700], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attention Needed',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${overdueRentals.length} rentals are overdue',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[300]),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentRentalsList(BuildContext context) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        if (state is RentalLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RentalLoaded) {
          if (state.rentals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No rentals yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          final sortedRentals = List<Rental>.from(state.rentals)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recentRentals = sortedRentals.take(5).toList();

          return Column(
            children: recentRentals.map((rental) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RentalTile(rental: rental),
            )).toList(),
          );
        } else if (state is RentalError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox();
      },
    );
  }
}
