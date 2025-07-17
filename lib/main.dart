import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/register_screen3.dart';  // Importa la pantalla de Register
 // Si tienes una pantalla de carga
import 'services/auth_layout.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Aquí colocamos AuthLayout para que maneje la navegación
      home: const AuthLayout(),
      // Rutas de navegación
      routes: {
        '/register': (context) => RegisterScreen3(),
      },
    );
  }
}