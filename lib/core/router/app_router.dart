import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../presentation/views/home_page.dart';
import '../../presentation/views/profile_page.dart';
import '../../presentation/views/add_rental_page.dart';
import '../../presentation/views/rental_details_page.dart';
import '../../presentation/views/all_rentals_page.dart';
import '../../presentation/views/login_page.dart';
import '../../presentation/views/splash_page.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/rental.dart';
import '../../domain/entities/car.dart';
import '../../presentation/views/add_car_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(di.sl<AuthBloc>().stream),
    redirect: (context, state) {

      final authState = context.read<AuthBloc>().state;
      final isSplash = state.uri.path == '/splash';
      final isLogin = state.uri.path == '/login';
      
      // If initial state, stay on splash
      if (authState is AuthInitial) {
        return isSplash ? null : '/splash';
      }
      
      final authenticated = authState is AuthAuthenticated;
      
      // If not authenticated and not on login page, redirect to login
      if (!authenticated) {
        return isLogin ? null : '/login';
      }
      
      // If authenticated and on login or splash page, redirect to home
      if (authenticated && (isLogin || isSplash)) {
        return '/home';
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
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
      GoRoute(
        path: '/add-car',
        name: 'add-car',
        builder: (context, state) {
          final car = state.extra as Car?;
          return AddCarPage(car: car);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
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
