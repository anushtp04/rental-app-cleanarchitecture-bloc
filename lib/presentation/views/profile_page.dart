import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/rental.dart';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<RentalBloc>().add(LoadRentals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              // Dark Mode Toggle
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  final isDark = state is ThemeLoaded && state.isDark;
                  return IconButton(
                    icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
                    onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
                  );
                },
              ),
              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                onPressed: () => _showLogoutDialog(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildCompactHeader(),
                  const SizedBox(height: 20),
                  _buildDashboardSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userEmail = 'user@example.com';
        if (authState is AuthAuthenticated) {
          userEmail = authState.email;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[200]!, width: 2),
                ),
                child: Center(
                  child: Text(
                    userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Admin User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.verified, color: Colors.blue[400], size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardSection() {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        if (state is! RentalLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final rentals = state.rentals;
        
        // --- Calculations ---
        final now = DateTime.now();
        final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final monthStart = DateTime(now.year, now.month, 1);

        double calculateRevenue(List<Rental> items) {
          return items.fold(0, (sum, item) {
            if (item.isCancelled && item.cancellationAmount != null) {
              return sum + item.cancellationAmount!;
            } else if (item.status == RentalStatus.completed && item.isCommissionBased == false) {
              return sum + item.totalAmount;
            }
            return sum;
          });
        }

        double calculateCommission(List<Rental> items) {
          return items
              .where((r) => r.isCommissionBased && !r.isCancelled && r.status == RentalStatus.completed)
              .fold(0.0, (sum, item) => sum + item.totalAmount);
        }

        // Filter rentals for week and month using same logic as graph
        final weekRentals = rentals.where((r) {
          // For completed rentals, use actualReturnDate
          if (r.status == RentalStatus.completed && r.actualReturnDate != null) {
            final returnDate = r.actualReturnDate!;
            return returnDate.isAtSameMomentAs(weekStart) || returnDate.isAfter(weekStart);
          }
          // For cancelled rentals with cancellation amount, use createdAt
          if (r.isCancelled && r.cancellationAmount != null) {
            final createdDate = r.createdAt;
            return createdDate.isAtSameMomentAs(weekStart) || createdDate.isAfter(weekStart);
          }
          return false;
        }).toList();
        
        final monthRentals = rentals.where((r) {
          // For completed rentals, use actualReturnDate
          if (r.status == RentalStatus.completed && r.actualReturnDate != null) {
            final returnDate = r.actualReturnDate!;
            return returnDate.isAtSameMomentAs(monthStart) || returnDate.isAfter(monthStart);
          }
          // For cancelled rentals with cancellation amount, use createdAt
          if (r.isCancelled && r.cancellationAmount != null) {
            final createdDate = r.createdAt;
            return createdDate.isAtSameMomentAs(monthStart) || createdDate.isAfter(monthStart);
          }
          return false;
        }).toList();

        final weekRevenue = calculateRevenue(weekRentals);
        final weekCommission = calculateCommission(weekRentals);
        final monthRevenue = calculateRevenue(monthRentals);
        final monthCommission = calculateCommission(monthRentals);
        final totalRevenue = calculateRevenue(rentals);
        final totalCommission = calculateCommission(rentals);

        final activeRentals = rentals
            .where((r) => (r.status == RentalStatus.ongoing || r.status == RentalStatus.overdue) && !r.isCancelled)
            .length;

        final overdueRentals = rentals
            .where((r) => r.status == RentalStatus.overdue && !r.isCancelled)
            .length;

        final List<DailyStats> weeklyData = List.generate(7, (index) {
          final day = now.subtract(Duration(days: 6 - index));
          final dayDate = DateTime(day.year, day.month, day.day);
          
          // Filter rentals based on completion date for completed rentals, creation date for others
          final dayRentals = rentals.where((r) {
            // For completed rentals, use actualReturnDate
            if (r.status == RentalStatus.completed && r.actualReturnDate != null) {
              final returnDate = r.actualReturnDate!;
              final returnDateOnly = DateTime(returnDate.year, returnDate.month, returnDate.day);
              return returnDateOnly.isAtSameMomentAs(dayDate);
            }
            // For cancelled rentals with cancellation amount, use createdAt
            if (r.isCancelled && r.cancellationAmount != null) {
              final createdDate = r.createdAt;
              final createdDateOnly = DateTime(createdDate.year, createdDate.month, createdDate.day);
              return createdDateOnly.isAtSameMomentAs(dayDate);
            }
            return false;
          }).toList();
          
          return DailyStats(
            date: day,
            revenue: calculateRevenue(dayRentals),
            commission: calculateCommission(dayRentals),
          );
        });

        return Column(
          children: [
            // Quick Actions / Status Chips
            Row(
              children: [
                Expanded(child: _buildStatusChip('Active Rentals', activeRentals.toString(), Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusChip('Overdue', overdueRentals.toString(), Colors.red, isAlert: overdueRentals > 0)),
              ],
            ),
            const SizedBox(height: 20),

            // Minimalist Graph
            _RevenueGraph(data: weeklyData),

            const SizedBox(height: 16),

            // Compact 2x2 Stats Grid
            Row(
              children: [
                Expanded(child: _buildCompactTile('Week Revenue', weekRevenue, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildCompactTile('Week Comm.', weekCommission, Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCompactTile('Month Revenue', monthRevenue, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildCompactTile('Month Comm.', monthCommission, Colors.purple)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Combined All Time Tile
            _buildCombinedAllTimeTile(totalRevenue, totalCommission),
            

          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String label, String value, Color color, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? Colors.red.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAlert ? Icons.warning_amber_rounded : Icons.circle,
            size: 12,
            color: isAlert ? Colors.red : color,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isAlert ? Colors.red.shade700 : Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isAlert ? Colors.red.shade400 : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTile(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedAllTimeTile(double totalRevenue, double totalCommission) {
    final grandTotal = totalRevenue + totalCommission;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Value Generated',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(grandTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBreakdownItem('Revenue', totalRevenue, Colors.blueAccent),
                Container(
                  height: 16,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white24,
                ),
                _buildBreakdownItem('Commission', totalCommission, Colors.purpleAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double amount, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(width: 4),
        Text(
          _formatCompact(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String _formatCompact(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

class DailyStats {
  final DateTime date;
  final double revenue;
  final double commission;

  DailyStats({required this.date, required this.revenue, required this.commission});
}

class _RevenueGraph extends StatefulWidget {
  final List<DailyStats> data;

  const _RevenueGraph({required this.data});

  @override
  State<_RevenueGraph> createState() => _RevenueGraphState();
}

class _RevenueGraphState extends State<_RevenueGraph> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final maxVal = widget.data.map((e) => e.revenue + e.commission).reduce((curr, next) => curr > next ? curr : next);
    final normalizedMax = maxVal > 0 ? maxVal : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trends (7 Days)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.data.length, (index) {
                final item = widget.data[index];
                final totalAmount = item.revenue + item.commission;
                final height = (totalAmount / normalizedMax) * 100;
                final dayLabel = DateFormat('E').format(item.date)[0];
                final fullDateLabel = DateFormat('MMM dd').format(item.date);
                final isTouched = touchedIndex == index;

                return GestureDetector(
                  onLongPressStart: (_) => setState(() => touchedIndex = index),
                  onLongPressEnd: (_) => setState(() => touchedIndex = null),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Labels - show full format when touched, compact otherwise
                      if (totalAmount > 0)
                      Column(
                        children: [
                          Text(
                            isTouched 
                              ? _formatFullCurrency(totalAmount)
                              : _formatCompact(totalAmount),
                            style: TextStyle(
                              fontSize: isTouched ? 11 : 9,
                              fontWeight: FontWeight.bold,
                              color: isTouched ? Colors.black : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isTouched ? 28 : 20,
                        height: height > 0 ? height : 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isTouched 
                              ? [Colors.black, Colors.grey.shade800]
                              : index == 6 
                                ? [Colors.black, Colors.grey.shade800]
                                : [Colors.grey.shade300, Colors.grey.shade400],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isTouched ? fullDateLabel : dayLabel,
                        style: TextStyle(
                          fontSize: isTouched ? 9 : 10,
                          color: isTouched || index == 6 ? Colors.black : Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  String _formatFullCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}
