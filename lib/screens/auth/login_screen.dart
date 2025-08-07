// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../auth/register_screen.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.login(_emailController.text.trim(), _passwordController.text.trim());

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password'), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Background gradient
              Container(
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.1),
                          // Logo and title
                          Hero(
                            tag: 'app-logo',
                            child: Material(
                              color: Colors.transparent,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/logo.png')),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Materials Exchange',
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text('Connect with your school community', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 40),

                          // Login card
                          Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              child: Container(
                                width: 400,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text('Welcome Back', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          hint: 'Enter your email',
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: _passwordController,
                                          label: 'Password',
                                          hint: 'Enter your password',
                                          prefixIcon: Icons.lock_outline,
                                          obscureText: _obscurePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                            if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        // Align(
                                        //   alignment: Alignment.centerRight,
                                        //   child: TextButton(
                                        //     onPressed: () {
                                        //       Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                                        //     },
                                        //     child: Text('Forgot Password?', style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor)),
                                        //   ),
                                        // ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _login,
                                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                            child: _isLoading
                                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : const Text('Login', style: TextStyle(fontSize: 16)),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                              },
                                              child: Text(
                                                'Register',
                                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
