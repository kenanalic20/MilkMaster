import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';
import 'package:milkmaster_desktop/providers/auth_provider.dart';
import 'package:milkmaster_desktop/screens/products_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.04),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.04),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(
                            r'^(?=.*[A-Z])(?=.*\d).{8,}$',
                          ).hasMatch(value)) {
                            return 'Password must contain at least one uppercase letter and one number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  _authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  );
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final username = _usernameController.text;
                                    final password = _passwordController.text;

                                    bool success = false;
                                    try {
                                      success = await _authProvider.login(
                                        username,
                                        password,
                                      );
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (e.toString().contains(
                                        'NETWORK_ERROR',
                                      )) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder:
                                              (
                                                BuildContext context,
                                              ) => AlertDialog(
                                                title: const Text(
                                                  'Connection Error',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                content: const Text(
                                                  'Unable to connect to the server. Please check your internet connection or try again later.',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      }
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (!success) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (
                                              BuildContext context,
                                            ) => AlertDialog(
                                              title: Text("Login Failed"),
                                              content: Text(
                                                "Login failed. Username or password is incorrect",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            ),
                                      );
                                      return;
                                    }
                                    final user = _authProvider.currentUser;
                                    if (user == null ||
                                        !user.roles.contains('Admin')) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text("Access Denied"),
                                              content: Text(
                                                "You do not have admin privileges.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            ),
                                      );
                                      return;
                                    }

                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/home');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Logging in as: $username',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                    );
                                  }
                                },
                        child: Text('Login'),
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
