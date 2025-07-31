import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '/screens/home/main_screen.dart';
import '/screens/home/home_screen.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/buttons/social_button.dart';
import '../../widgets/shared/divider_with_text.dart';
import '../../widgets/text/title_text.dart';
import '../../widgets/text/subtitle_text.dart';
import '../../screens/auth/login_screen.dart';

class RegisterScreen3 extends StatefulWidget {
  const RegisterScreen3({super.key});

  @override
  _RegisterScreen3State createState() => _RegisterScreen3State();
}

class _RegisterScreen3State extends State<RegisterScreen3> {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  void register() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final userCredential = await authService.value.createAccount(
          email: controllerEmail.text.trim(),
          password: controllerPassword.text.trim(),
        );

        // ✅ Obtener token de Firebase
        final idToken = await userCredential.user!.getIdToken();
        if (idToken == null) {
          throw Exception('No se pudo obtener el token de autenticación');
        }
        await createMongoUser(idToken);

        // ✅ Crear usuario en MongoDB
        await createMongoUser(idToken);

        // ✅ Refrescar AuthService y navegar
        authService.value = AuthService();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'Error creating account';
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Error al crear cuenta: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9ECFFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleText('Register'),
                const SizedBox(height: 8),
                const SubtitleText(
                  'Create an account or log in to explore our app',
                ),
                const SizedBox(height: 24),

                // Botón Google
                SocialButton(
                  icon: Icons.g_mobiledata,
                  text: 'Sign in with Google',
                  onPressed: () {},// reemplazar con lógica real
                ),
                const SizedBox(height: 12),

                // Botón Facebook
                SocialButton(
                  icon: Icons.facebook,
                  text: 'Sign in with Facebook',
                  onPressed: () {}, // reemplazar con lógica real
                ),
                const SizedBox(height: 20),

                // Separador
                const DividerWithText(text: "Or"),
                const SizedBox(height: 20),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: controllerEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your email';
                          final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          if (!regex.hasMatch(value)) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: controllerPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your password';
                          if (value.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Error
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      const SizedBox(height: 20),

                      // Botón Register
                      CustomButton(
                        text: 'Register',
                        onPressed: register,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}