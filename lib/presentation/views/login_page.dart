import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSendOtpRequested(
              email: _emailController.text,
            ),
          );
    }
  }

  void _handleVerifyOtp() {
    if (_otpController.text.isNotEmpty) {
      context.read<AuthBloc>().add(
            AuthVerifyOtpRequested(
              email: _emailController.text,
              token: _otpController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthOtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP sent to ${state.email}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final isOtpSent = state is AuthOtpSent;
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or App Icon
                      Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Car Rental App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOtpSent ? 'Enter the OTP sent to your email' : 'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Email Field (Always visible, disabled if OTP sent)
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !isOtpSent && !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      if (isOtpSent) ...[
                        const SizedBox(height: 16),
                        // OTP Field
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleVerifyOtp(),
                          decoration: InputDecoration(
                            labelText: 'OTP',
                            hintText: 'Enter 8-digit OTP',
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the OTP';
                            }
                            if (value.length < 6) {
                              return 'OTP must be 8 digits';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 32),
                      
                      // Action Button
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : (isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isOtpSent ? 'Verify OTP' : 'Send OTP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      
                      if (isOtpSent)
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // Reset to initial state (handled by parent or just reset bloc?)
                                  // Since we are in AuthOtpSent state, we might need an event to reset
                                  // or just re-emit AuthInitial/AuthUnauthenticated.
                                  // For now, let's just let the user edit email by "cancelling"
                                  // But wait, the bloc state is persistent.
                                  // We need a way to "Cancel" OTP.
                                  // Let's add a "Change Email" button that emits AuthUnauthenticated or similar.
                                  // Or just reload the page/bloc.
                                  context.read<AuthBloc>().add(AuthLogoutRequested()); // Reset state
                                },
                          child: const Text('Change Email'),
                        ),

                      const SizedBox(height: 16),
                      
                      // Info Text
                      Text(
                        'Note: Only registered emails can sign in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

