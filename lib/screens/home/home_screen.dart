// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../auth/change_password_screen.dart';
import '../auth/delete_account_screen.dart';
import '../auth/update_username_screen.dart';
import '../welcome_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _ciudad = 'Cargando ubicación...'; // Inicializar con un mensaje
  bool _ubicacionAutorizada = false;  // Variable para manejar el estado de autorización

  // Función para obtener la ciudad
  Future<String> obtenerCiudad() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return 'Servicio de ubicación deshabilitado';
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      // Solicitar el permiso
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return 'Permiso de ubicación denegado';
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return 'Permiso de ubicación permanentemente denegado';
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      List<Placemark> lugares = await placemarkFromCoordinates(posicion.latitude, posicion.longitude);
      Placemark lugar = lugares[0];
      setState(() {
        _ciudad = lugar.locality ?? 'Ciudad desconocida';
        _ubicacionAutorizada = true;  // Cambiar estado cuando la ubicación se obtiene
      });
      return _ciudad;
    } catch (e) {
      setState(() {
        _ciudad = 'Error al obtener ubicación: $e';
        _ubicacionAutorizada = false;
      });
      return _ciudad;
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCiudad();  // Llamar a la función para obtener la ciudad cuando se inicie la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
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
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Estás logeado en MySpot',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    // Mostrar la ciudad solo si los permisos están autorizados
                    if (_ubicacionAutorizada)
                      Text(
                        'Estás en $_ciudad',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    else
                      const Text(
                        'Autorización de acceso a ubicación en proceso...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    const SizedBox(height: 30),
                    // Resto de los botones y widgets...
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