import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/category.dart';
import '../../widgets/cards/PopularPlaceCard.dart';
import '../../widgets/cards/place_card.dart';
import '../../services/place_service.dart';

List<Place> _popularPlaces = [];
List<DetailedPlace> _allPlaces = [];

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
  List<String> categories = ['Location'];

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Variables para scroll infinito
  Future<void> _cargarCategorias() async {
    try {
      final List<CategoryModel> response = await PlaceService.fetchCategories();
      setState(() {
        categories = ['Location', ...response.map((cat) => cat.name)];
      });
    } catch (e) {
      _mostrarError(context, 'Error al cargar categorías');
    }
  }
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
      cargarLugares();
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
      final endIndex = (startIndex + _placesPerPage).clamp(0, _allPlaces.length);

      final newPlaces = _allPlaces.sublist(startIndex, endIndex);

      setState(() {
        _displayedPlaces.addAll(newPlaces);
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  Future<void> cargarLugares() async {
    try {
      // Llamada sin ciudad → obtiene los lugares más populares globalmente
      final populares = await PlaceService.fetchPopularPlaces();
      final cercanos = await PlaceService.fetchNearbyPlaces(20.11, -98.77); // Puedes reemplazar por la ubicación real

      setState(() {
        _popularPlaces = populares.map((json) => Place(
          title: json['name'],
          imagePath: json['main_image_url'],
          rating: (json['average_rating'] ?? 0.0).toDouble(),
          isFavorite: false,
          category: json['category'],
        )).toList();

        _allPlaces = cercanos.map((json) => DetailedPlace(
          title: json['name'],
          imagePath: json['main_image_url'],
          rating: (json['average_rating'] ?? 0.0).toDouble(),
          isFavorite: false,
          category: json['category'],
          location: '${json['location']['city']}, ${json['location']['state']}',
          reviewCount: json['review_count'] ?? 0,
          tags: List<String>.from(json['tags'] ?? []),
        )).toList();

        _displayedPlaces = [..._allPlaces.take(_placesPerPage)];
      });
    } catch (e) {
      _mostrarError(context, 'Error al cargar lugares');
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCiudad();
    _cargarCategorias();
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
    return _displayedPlaces.toSet().toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_ciudadSeleccionada == null || _ciudadSeleccionada!.isEmpty) {
      _ciudadSeleccionada = 'Near places';
    }

    final lugaresFiltrados = _categoriaSeleccionada == 'Location'
        ? _popularPlaces
        : _popularPlaces.where((place) => place.category == _categoriaSeleccionada).toList();

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
      height: 36, // Altura consistente para centrar el texto
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center, // Centra el texto vertical y horizontalmente
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}