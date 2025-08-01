import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/navigation/custom_bottom_navbar.dart';
import 'location_screen.dart'; // ✅ Importamos la pantalla del mapa

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.blue.shade100,
        ),
        body: FutureBuilder<String?>(
          future: FirebaseAuth.instance.currentUser?.getIdToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('No se pudo obtener el token.'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  'Token JWT:\n\n${snapshot.data}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    LocationScreen(), // ✅ Aquí se muestra el mapa
    DummyScreen(title: 'Favoritos'),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
