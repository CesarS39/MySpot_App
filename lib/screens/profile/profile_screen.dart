import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/text/title_text.dart';
import '../../widgets/text/subtitle_text.dart';
import '../../widgets/navigation/custom_bottom_navbar.dart';
import '../place/place_detail_screen.dart';
import '../auth/change_password_screen.dart';
import '../auth/delete_account_screen.dart';
import '../auth/update_username_screen.dart';
import '../welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    void showLoginStatus() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estás logeado como ${user?.email ?? 'usuario desconocido'}'),
          backgroundColor: Colors.green,
        ),
      );
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
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const NetworkImage('https://i.pravatar.cc/300'),
            ),
            const SizedBox(height: 12),
            TitleText(user?.displayName ?? 'Usuario'),
            SubtitleText(user?.email ?? 'usuario@email.com'),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  children: [
                    _buildProfileCard(
                      icon: Icons.verified_user,
                      iconColor: Colors.indigoAccent,
                      title: 'Verificar estado de login',
                      subtitle: 'Confirma tu sesión actual',
                      onTap: showLoginStatus,
                    ),
                    _buildProfileCard(
                      icon: Icons.edit,
                      iconColor: Colors.blue,
                      title: 'Editar nombre de usuario',
                      subtitle: 'Actualiza tu información personal',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UpdateUsernameScreen())
                        );
                      },
                    ),
                    _buildProfileCard(
                      icon: Icons.lock_reset,
                      iconColor: Colors.teal,
                      title: 'Cambiar contraseña',
                      subtitle: 'Actualiza tu contraseña de acceso',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordScreen())
                        );
                      },
                    ),
                    _buildProfileCard(
                      icon: Icons.settings,
                      iconColor: Colors.blueGrey,
                      title: 'Configuración de la cuenta',
                      subtitle: 'Ajusta tus preferencias',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración próximamente')),
                        );
                      },
                    ),
                    _buildProfileCard(
                      icon: Icons.logout,
                      iconColor: Colors.redAccent,
                      title: 'Cerrar sesión',
                      subtitle: 'Salir de tu cuenta',
                      textColor: Colors.redAccent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cerrar sesión'),
                              content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    'Cerrar sesión',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    logout();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    _buildProfileCard(
                      icon: Icons.delete_forever,
                      iconColor: Colors.red,
                      title: 'Eliminar cuenta',
                      subtitle: 'Eliminar permanentemente tu cuenta',
                      textColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DeleteAccountScreen())
                        );
                      },
                    ),
                    _buildProfileCard(
                      icon: Icons.place,
                      iconColor: Colors.deepPurple,
                      title: 'Probar pantalla de lugar',
                      subtitle: 'Navegar con datos simulados',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/place_detail',
                          arguments: '688a496ad6994bc8d79f3673',
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0.3,
        color: const Color(0xFFFBFBFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF5F5F5), width: 0.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor ?? Colors.black87,
                          )),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}