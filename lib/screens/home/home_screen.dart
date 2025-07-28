import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/cards/PopularPlaceCard.dart'; // Asegúrate de tenerlo
// import '../../services/place_service.dart'; // Si luego conectas a backend

class Place {
  final String title;
  final String imagePath;
  final double rating;
  final bool isFavorite;
  final String category;

  const Place({
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.isFavorite,
    required this.category,
  });
}

const List<Place> popularPlaces = [
  Place(title: 'Grutas de Tolantongo', imagePath: 'lib/images/grutas.jpg', rating: 4.5, isFavorite: true, category: 'Adventure'),
  Place(title: 'Basílica de Guadalupe', imagePath: 'lib/images/grutas.jpg', rating: 4.7, isFavorite: false, category: 'Culture'),
  Place(title: 'Xcaret Park', imagePath: 'lib/images/grutas.jpg', rating: 4.8, isFavorite: true, category: 'Nature'),
  Place(title: 'Museo Frida Kahlo', imagePath: 'lib/images/grutas.jpg', rating: 4.6, isFavorite: false, category: 'Culture'),
  Place(title: 'Chichén Itzá', imagePath: 'lib/images/grutas.jpg', rating: 4.9, isFavorite: true, category: 'Culture'),
  Place(title: 'Cenote Ik Kil', imagePath: 'lib/images/grutas.jpg', rating: 4.4, isFavorite: false, category: 'Nature'),
  Place(title: 'Teotihuacán', imagePath: 'lib/images/grutas.jpg', rating: 4.7, isFavorite: true, category: 'Culture'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _ciudad = 'Cargando ubicación...';
  String _pais = '';
  bool _ubicacionAutorizada = false;
  List<String> _ciudadesCercanas = [];
  String? _ciudadSeleccionada = 'Near places';

  String _categoriaSeleccionada = 'Location';
  final List<String> categories = ['Location', 'Hotels', 'Food', 'Adventure', 'Culture', 'Nature'];

  Future<void> obtenerCiudad() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    if (permiso == LocationPermission.deniedForever) return;

    try {
      Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> lugares = await placemarkFromCoordinates(posicion.latitude, posicion.longitude);
      Placemark lugar = lugares.first;

      final String country = lugar.country ?? '';
      final String jsonString = await rootBundle.loadString('assets/data/cities_by_country.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _ciudadesCercanas = List<String>.from(jsonMap[country] ?? []);

      setState(() {
        _ciudad = lugar.locality ?? 'Ciudad desconocida';
        _pais = country;
        _ubicacionAutorizada = true;
        _ciudadSeleccionada = 'Near places';
      });
    } catch (e) {
      setState(() {
        _ciudad = 'Error al obtener ubicación';
        _ubicacionAutorizada = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCiudad();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_ciudadSeleccionada == null || _ciudadSeleccionada!.isEmpty) {
      _ciudadSeleccionada = 'Near places';
    }

    final lugaresFiltrados = _categoriaSeleccionada == 'Location'
        ? popularPlaces
        : popularPlaces.where((place) => place.category == _categoriaSeleccionada).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado superior: Explore + dropdown en la misma línea
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Explore", style: TextStyle(fontSize: 20, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            value: _ciudadSeleccionada,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
                            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                            items: ['Near places', ..._ciudadesCercanas].map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null && value != _ciudadSeleccionada) {
                                setState(() => _ciudadSeleccionada = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ciudadSeleccionada != null && _ciudadSeleccionada != 'Near places'
                        ? _ciudadSeleccionada!
                        : _ciudad,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Find things to do',
                    icon: Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Categorías
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _categoriaSeleccionada = cat;
                          });
                        },
                        child: CategoryChip(text: cat, selected: _categoriaSeleccionada == cat),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Sección Popular
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Popular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("See all", style: TextStyle(color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 12),

              // Lista horizontal de lugares filtrados
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: lugaresFiltrados.map((place) => PopularPlaceCard(
                    imagePath: place.imagePath,
                    title: place.title,
                    rating: place.rating,
                    isFavorite: place.isFavorite,
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;

  const CategoryChip({super.key, required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}