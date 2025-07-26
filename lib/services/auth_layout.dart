import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/loading/loading_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/welcome_screen.dart';


import 'auth_service.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,  // Aquí no agregues los paréntesis
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = AppLoadingPage();  // Mientras se espera el estado de autenticación
            } else if (snapshot.hasData) {
              widget = const MainScreen();  // Si el usuario está autenticado, ir a HomeScreen
            } else {
              widget = pageIfNotConnected ?? const WelcomeScreen();  // Si no está autenticado, ir a WelcomeScreen
            }
            return widget;
          },
        );
      },
    );
  }
}