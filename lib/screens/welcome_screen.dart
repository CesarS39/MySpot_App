import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/register_screen3.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/text/title_text.dart';
import '../widgets/text/subtitle_text.dart';
import '../widgets/shared/divider_with_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔁 Redirige automáticamente si el usuario ya está logueado
    if (user != null) {
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'lib/images/Tst.jpg', // Cambiar el nombre si usas otra imagen
                fit: BoxFit.cover, // La imagen se adapta a toda la pantalla
              ),
            ),
          ),

          // Contenido superpuesto
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Título de la aplicación
                  const Text(
                    'MySPOT',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Aseguramos que el texto sea blanco
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo
                  const SubtitleText(
                    "Start your journey by creating an account or logging in",
                  ),
                  const SizedBox(height: 24),

                  // Texto "Explore the Best Places"
                  const Text(
                    "Explore the Best Places",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Hacemos el texto blanco para resaltar
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Start
                  CustomButton(
                    text: 'Start',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen3()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón Login
                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divider y "Or"
                  const DividerWithText(text: "Or"),
                  const SizedBox(height: 24),

                  // Botón para verificar el estado de login
                  CustomButton(
                    text: 'Verificar estado de login',
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      final message = user != null
                          ? 'Estás logeado como ${user.email}'
                          : 'No estás logeado';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}