// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../auth/change_password_screen.dart';
import '../auth/delete_account_screen.dart';
import '../auth/update_username_screen.dart';
import '../welcome_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        void logout() async {
          try {
            await authService.value.signOut();
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
            );
          } catch (e) {
            print('Error al cerrar sesión: $e');
          }
        }


        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Center(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Colors.white.withOpacity(0.85),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hola, ${user?.displayName ?? 'usuario'}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,  // Cambio: era Colors.deepPurple
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Estás logeado en MySpot',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      icon: const Icon(Icons.verified_user),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Estás logeado como ${user?.email ?? 'usuario desconocido'}'),
                            backgroundColor: Colors.blue,  // Consistencia
                          ),
                        );
                      },
                      label: const Text('Verificar estado de login'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,  // Cambio: era Colors.deepPurpleAccent
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateUsernameScreen()));
                      },
                      label: const Text('Editar nombre de usuario'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.lightBlue,  // Cambio: era Colors.purple.shade200
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.lock_reset),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                      },
                      label: const Text('Cambiar contraseña'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.cyan,  // Cambio: era Colors.teal.shade200
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.logout),
                      onPressed: logout,
                      label: const Text('Cerrar sesión'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade100,  // Mantener rojo para logout
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
                      },
                      label: const Text(
                        'Eliminar cuenta',
                        style: TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black54),
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}