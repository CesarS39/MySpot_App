import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/cards/PopularPlaceCard.dart';
import '../../widgets/cards/place_card.dart';

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

// Nuevo modelo para lugares del scroll infinito
class DetailedPlace {
  final String title;
  final String imagePath;
  final double rating;
  final bool isFavorite;
  final String category;
  final String location;
  final int reviewCount;
  final List<String> tags;

  const DetailedPlace({
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.isFavorite,
    required this.category,
    required this.location,
    required this.reviewCount,
    required this.tags,
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

// Datos de ejemplo para el scroll infinito
List<DetailedPlace> allPlaces = [
  const DetailedPlace(
    title: 'Restaurante La Cocina de María',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.2,
    isFavorite: false,
    category: 'Food',
    location: 'Centro Histórico, Ciudad de México',
    reviewCount: 245,
    tags: ['Comida tradicional', 'Ambiente acogedor', 'Precio accesible'],
  ),
  const DetailedPlace(
    title: 'Hotel Boutique Casa Colonial',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.6,
    isFavorite: true,
    category: 'Hotels',
    location: 'San Miguel de Allende, Guanajuato',
    reviewCount: 189,
    tags: ['Arquitectura colonial', 'Servicio premium', 'Ubicación céntrica'],
  ),
  const DetailedPlace(
    title: 'Cascadas de Agua Azul',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.8,
    isFavorite: true,
    category: 'Nature',
    location: 'Tumbalá, Chiapas',
    reviewCount: 567,
    tags: ['Cascadas', 'Senderismo', 'Fotografía'],
  ),
  const DetailedPlace(
    title: 'Tour en Globo Aerostático',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.9,
    isFavorite: false,
    category: 'Adventure',
    location: 'Valle de Bravo, Estado de México',
    reviewCount: 134,
    tags: ['Vuelo panorámico', 'Amanecer', 'Experiencia única'],
  ),
  const DetailedPlace(
    title: 'Museo de Antropología',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.7,
    isFavorite: true,
    category: 'Culture',
    location: 'Chapultepec, Ciudad de México',
    reviewCount: 892,
    tags: ['Historia prehispánica', 'Arte', 'Educativo'],
  ),
  const DetailedPlace(
    title: 'Café de Especialidad Origen',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.3,
    isFavorite: false,
    category: 'Food',
    location: 'Roma Norte, Ciudad de México',
    reviewCount: 156,
    tags: ['Café artesanal', 'Wi-Fi', 'Ambiente hipster'],
  ),
  const DetailedPlace(
    title: 'Playa Maroma Resort',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.5,
    isFavorite: true,
    category: 'Hotels',
    location: 'Riviera Maya, Quintana Roo',
    reviewCount: 423,
    tags: ['Todo incluido', 'Playa privada', 'Spa'],
  ),
  const DetailedPlace(
    title: 'Parque Nacional Pico de Orizaba',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.4,
    isFavorite: false,
    category: 'Nature',
    location: 'Chalchicomula, Puebla',
    reviewCount: 78,
    tags: ['Montañismo', 'Flora y fauna', 'Camping'],
  ),
  const DetailedPlace(
    title: 'Mercado de San Juan Gourmet',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.1,
    isFavorite: false,
    category: 'Food',
    location: 'Centro Histórico, Ciudad de México',
    reviewCount: 324,
    tags: ['Comida exótica', 'Productos gourmet', 'Experiencia única'],
  ),
  const DetailedPlace(
    title: 'Hotel Casa de Sierra Nevada',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.8,
    isFavorite: true,
    category: 'Hotels',
    location: 'San Miguel de Allende, Guanajuato',
    reviewCount: 156,
    tags: ['Lujo', 'Spa', 'Arquitectura colonial'],
  ),
  const DetailedPlace(
    title: 'Reserva de la Biosfera Sian Ka\'an',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.6,
    isFavorite: true,
    category: 'Nature',
    location: 'Tulum, Quintana Roo',
    reviewCount: 234,
    tags: ['Patrimonio UNESCO', 'Ecoturismo', 'Vida silvestre'],
  ),
  const DetailedPlace(
    title: 'Rafting en Río Filobobos',
    imagePath: 'lib/images/grutas.jpg',
    rating: 4.3,
    isFavorite: false,
    category: 'Adventure',
    location: 'Tlapacoyan, Veracruz',
    reviewCount: 89,
    tags: ['Deportes extremos', 'Rafting', 'Adrenalina'],
  ),
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

  // Variables para scroll infinito
  final ScrollController _scrollController = ScrollController();
  List<DetailedPlace> _displayedPlaces = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  static const int _placesPerPage = 4;

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

  void _loadMorePlaces() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simular carga de datos (reemplaza con tu lógica de API)
    Future.delayed(const Duration(seconds: 1), () {
      final startIndex = _currentPage * _placesPerPage;
      final endIndex = (startIndex + _placesPerPage).clamp(0, allPlaces.length);

      final newPlaces = List.generate(
        endIndex - startIndex,
            (index) => allPlaces[(startIndex + index) % allPlaces.length],
      );

      setState(() {
        _displayedPlaces.addAll(newPlaces);
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerCiudad();
    _loadMorePlaces(); // Cargar primeros lugares

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMorePlaces();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DetailedPlace> get _filteredPlaces {
    if (_categoriaSeleccionada == 'Location') {
      return _displayedPlaces;
    }
    return _displayedPlaces.where((place) => place.category == _categoriaSeleccionada).toList();
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
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado superior
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

                  // Lista horizontal de lugares populares
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

                  const SizedBox(height: 30),

                  // Sección de todos los lugares
                  const Text("Todos los lugares", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Lista vertical con scroll infinito usando el widget importado
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final filteredPlaces = _filteredPlaces;

                if (index < filteredPlaces.length) {
                  final place = filteredPlaces[index];
                  return PlaceCard(
                    imagePath: place.imagePath,
                    title: place.title,
                    category: place.category,
                    rating: place.rating,
                    isFavorite: place.isFavorite,
                    location: place.location,
                    reviewCount: place.reviewCount,
                    tags: place.tags,
                  );
                } else if (index == filteredPlaces.length && _isLoadingMore) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return null;
              },
              childCount: _filteredPlaces.length + (_isLoadingMore ? 1 : 0),
            ),
          ),
        ],
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