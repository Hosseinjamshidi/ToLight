import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:todark/app/modules/home.dart';
import 'package:todark/app/services/auth_service.dart';
import 'package:todark/main.dart'; // Import to access global settings variable

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';
  bool _isLogin = true;

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      User? user;

      try {
        if (_isLogin) {
          user =
              await _authService.signInWithEmailAndPassword(_email, _password);
          if (user != null) {
            EasyLoading.showSuccess('Logged in successfully!');
            await initSettings(); // Initialize settings
          }
        } else {
          user = await _authService.registerWithEmailAndPassword(
              _email, _password);
          if (user != null) {
            EasyLoading.showSuccess('Registered successfully!');
            await initSettings(); // Initialize settings
          }
        }
        if (user != null) {
          Get.offAll(
              const HomePage()); // Redirect to home page after successful login/registration
        } else {
          EasyLoading.showError('Authentication failed');
        }
      } on FirebaseAuthException catch (e) {
        EasyLoading.showError(e.message ?? 'An error occurred');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(_isLogin ? 'Register' : 'Login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const ValueKey('email'),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email address'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                key: const ValueKey('password'),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitAuthForm,
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
