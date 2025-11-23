import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/views/home_page.dart';
import '../../presentation/views/profile_page.dart';
import '../../presentation/views/add_rental_page.dart';
import '../../presentation/views/rental_details_page.dart';
import '../../presentation/views/all_rentals_page.dart';
import '../../presentation/views/login_page.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/rental.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Get auth bloc from context if available, otherwise check service locator
      AuthBloc? authBloc;
      try {
        authBloc = context.read<AuthBloc>();
      } catch (e) {
        // If not in context, try service locator (for initial load)
        try {
          authBloc = di.sl<AuthBloc>();
        } catch (e) {
          // Auth bloc not available yet, allow navigation
          return null;
        }
      }
      
      final authState = authBloc.state;
      final isLoginRoute = state.uri.path == '/login';
      
      // If not authenticated and not on login page, redirect to login
      if (authState is! AuthAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      // If authenticated and on login page, redirect to home
      if (authState is AuthAuthenticated && isLoginRoute) {
        return '/home';
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/all-rentals',
            name: 'all-rentals',
            builder: (context, state) => const AllRentalsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-rental',
        name: 'add-rental',
        builder: (context, state) {
          final rental = state.extra as Rental?;
          return AddRentalPage(rental: rental);
        },
      ),
      GoRoute(
        path: '/rental-details',
        name: 'rental-details',
        builder: (context, state) {
          final rental = state.extra as Rental;
          return RentalDetailsPage(rental: rental);
        },
      ),
    ],
  );
}

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;

    if (location == '/home') {
      currentIndex = 0;
    } else if (location == '/all-rentals') {
      currentIndex = 1;
    } else if (location == '/profile') {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == 0) {
              context.go('/home');
            } else if (index == 1) {
              context.go('/all-rentals');
            } else if (index == 2) {
              context.go('/profile');
            }
          },
          elevation: 8,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'All Rentals',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
