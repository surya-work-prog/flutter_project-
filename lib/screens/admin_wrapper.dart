import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/login_screen.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';
import 'login_screen.dart';

class AdminWrapper extends StatelessWidget {
  AdminWrapper({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // logged in
        if (snapshot.hasData) {
          return const AdminScreen();
        }

        // not logged in
        return const LoginScreen();
      },
    );
  }
}