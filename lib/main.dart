import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/location_service.dart'; // Importa el servicio de ubicación
import 'screens/home/home_screen.dart'; // Importa la pantalla Home
import 'screens/auth/register_screen3.dart'; // Importa la pantalla de Register
import 'services/auth_layout.dart'; // Importa el layout para autenticación
import 'package:supabase/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa Supabase
  // Crea el cliente Supabase global (puedes moverlo a un servicio si lo prefieres)
  final supabase = SupabaseClient(
    'https://ftauvekkhkutiruepfkw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0YXV2ZWtraGt1dGlydWVwZmt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4NzkyNTksImV4cCI6MjA2OTQ1NTI1OX0.ef-4RxnGcSVjwSP1OtVSUb0meFOEIDQSLJl5E5oc7tM',
  );

  // Obtiene y guarda ubicación (si aplica)
  await _obtenerYGuardarUbicacion();

  runApp(const MyApp());
}

// Función para obtener y guardar la ubicación solo una vez al inicio
Future<void> _obtenerYGuardarUbicacion() async {
  final ubicacion = await LocationService.obtenerUbicacionGuardada();

  // Si no hay ubicación guardada, la obtenemos y guardamos
  if (ubicacion['lat'] == null || ubicacion['lon'] == null) {
    await LocationService.obtenerCiudad();  // Esto obtiene y guarda la ubicación automáticamente
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySpot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthLayout(),  // Pantalla de inicio de sesión/registro
      routes: {
        '/register': (context) => RegisterScreen3(),
        '/home': (context) => const HomeScreen(),  // Ruta para la pantalla principal (HomeScreen)
      },
    );
  }
}