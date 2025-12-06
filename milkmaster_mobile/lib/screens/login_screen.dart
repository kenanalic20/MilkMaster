import 'package:flutter/material.dart';
import 'package:milkmaster_mobile/providers/auth_provider.dart';
import 'package:milkmaster_mobile/providers/cart_provider.dart';
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
      body: Center(
        child: SingleChildScrollView(
          child: FractionallySizedBox(
            widthFactor: 0.9,
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
                    onPressed: () async {
                      _authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        final success = await _authProvider.login(
                          username,
                          password,
                        );
                        
                        if (mounted) Navigator.pop(context);
                
                        if (!success) {
                          showDialog(
                            context: context,
                            builder:
                                (BuildContext context) => AlertDialog(
                                  title: Text("Login Failed"),
                                  content: Text(
                                    "Login failed. Username or password is incorrect",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                          return;
                        }
                        final user = _authProvider.currentUser;
                        if (user == null || user.roles.contains('Admin')) {
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
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                          );
                          return; 
                        }
                
                        if (mounted) {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          try {
                            final userId = int.tryParse(user.id);
                            if (userId != null) {
                              await cartProvider.setUser(userId);
                            }
                          } catch (e) {
                            print('Error setting cart user: $e');
                          }
                        }
                
                        Navigator.of(context).pushReplacementNamed('/home');
                
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Logging in as: $username',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                    },
                    child: Text('Login'),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
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
    );
  }
}
