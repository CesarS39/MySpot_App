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
import '../../screens/place/place_detail_screen.dart';
import '../../services/place_notifier.dart';


List<Place> _popularPlaces = [];
List<DetailedPlace> _allPlaces = [];

class Place {
  final String id;
  final String title;
  final String imagePath;
  final double rating;
  final bool isFavorite;
  final String category;
  final bool isLiked;

  const Place({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.isFavorite,
    required this.category,
    required this.isLiked,
  });
}

// Nuevo modelo para lugares del scroll infinito
class DetailedPlace {
  final String id;
  final String title;
  final String imagePath;
  final double rating;
  final bool isFavorite;
  final String category;
  final String location;
  final int reviewCount;
  final List<String> tags;
  final bool isLiked;

  const DetailedPlace({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.isFavorite,
    required this.category,
    required this.location,
    required this.reviewCount,
    required this.tags,
    required this.isLiked,
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

    final startIndex = _currentPage * _placesPerPage;

    // ✅ Verificar si ya se cargaron todos los lugares
    if (startIndex >= _allPlaces.length) {
      return; // No hay más lugares que cargar
    }

    setState(() {
      _isLoadingMore = true;
    });

    // Simular carga de datos (reemplaza con tu lógica de API)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // ✅ Verificar si el widget sigue montado

      final endIndex = (startIndex + _placesPerPage).clamp(0, _allPlaces.length);

      // ✅ Solo continuar si hay lugares nuevos que agregar
      if (startIndex < _allPlaces.length) {
        final newPlaces = _allPlaces.sublist(startIndex, endIndex);

        setState(() {
          _displayedPlaces.addAll(newPlaces);
          _currentPage++;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  Future<void> cargarLugares() async {
    try {
      // Llamada sin ciudad → obtiene los lugares más populares globalmente
      final populares = await PlaceService.fetchPopularPlaces();
      final cercanos = await PlaceService.fetchNearbyPlaces(20.11, -98.77); // Puedes reemplazar por la ubicación real

      setState(() {
        _popularPlaces = populares.map((json) => Place(
          id: json['id'],
          title: json['name'],
          imagePath: json['main_image_url'],
          rating: (json['average_rating'] ?? 0.0).toDouble(),
          isFavorite: json['isLiked'] ?? false,
          category: json['category'],
          isLiked: json['isLiked'] ?? false,
        )).toList();

        _allPlaces = cercanos.map((json) => DetailedPlace(
          id: json['id'],
          title: json['name'],
          imagePath: json['main_image_url'],
          rating: (json['average_rating'] ?? 0.0).toDouble(),
          isFavorite: json['isLiked'] ?? false,
          category: json['category'],
          location: '${json['location']['city']}, ${json['location']['state']}',
          reviewCount: json['review_count'] ?? 0,
          tags: List<String>.from(json['tags'] ?? []),
          isLiked: json['isLiked'] ?? false,
        )).toList();

        // ✅ Reiniciar las variables de paginación
        _currentPage = 0;
        _displayedPlaces.clear();

        // ✅ Cargar la primera página
        final firstPageSize = _placesPerPage.clamp(0, _allPlaces.length);
        _displayedPlaces = [..._allPlaces.take(firstPageSize)];

        if (_displayedPlaces.isNotEmpty) {
          _currentPage = 1; // Ya cargamos la primera página
        }
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

    // ✅ NO llamar _loadMorePlaces aquí, se carga en cargarLugares()
    // _loadMorePlaces(); // ❌ Remover esta línea

    _scrollController.addListener(() {
      // ✅ Verificar que no esté ya cargando y que haya más contenido
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _displayedPlaces.length < _allPlaces.length) {
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
    // ✅ Crear un Map para garantizar unicidad por ID
    final Map<String, DetailedPlace> uniquePlacesMap = {};

    for (final place in _displayedPlaces) {
      uniquePlacesMap[place.id] = place;
    }

    // Convertir a lista y ordenar
    final List<DetailedPlace> uniquePlaces = uniquePlacesMap.values.toList();
    uniquePlaces.sort((a, b) => b.rating.compareTo(a.rating));

    return uniquePlaces;
  }

  // Manejar el cambio de like/favorite
  // Función corregida para manejar el cambio de like/favorite
  // Modificar la función _toggleLike en HomeScreen
  Future<void> _toggleLike(String placeId, bool currentValue) async {
    try {
      // Solo pasa el ID, el método devuelve el nuevo estado
      bool newState = await PlaceService.togglePlaceLike(placeId);

      setState(() {
        // Actualizar en lugares populares
        final indexPopular = _popularPlaces.indexWhere((p) => p.id == placeId);
        if (indexPopular != -1) {
          _popularPlaces[indexPopular] = Place(
            id: _popularPlaces[indexPopular].id,
            title: _popularPlaces[indexPopular].title,
            imagePath: _popularPlaces[indexPopular].imagePath,
            rating: _popularPlaces[indexPopular].rating,
            isFavorite: newState,
            category: _popularPlaces[indexPopular].category,
            isLiked: newState,
          );
        }

        // Actualizar en lugares detallados
        final indexDetailed = _displayedPlaces.indexWhere((p) => p.id == placeId);
        if (indexDetailed != -1) {
          _displayedPlaces[indexDetailed] = DetailedPlace(
            id: _displayedPlaces[indexDetailed].id,
            title: _displayedPlaces[indexDetailed].title,
            imagePath: _displayedPlaces[indexDetailed].imagePath,
            rating: _displayedPlaces[indexDetailed].rating,
            isFavorite: newState,
            category: _displayedPlaces[indexDetailed].category,
            location: _displayedPlaces[indexDetailed].location,
            reviewCount: _displayedPlaces[indexDetailed].reviewCount,
            tags: _displayedPlaces[indexDetailed].tags,
            isLiked: newState,
          );
        }
      });

      // ✅ NUEVO: Notificar el cambio globalmente
      PlaceNotifier().notifyLikeChanged(placeId, newState);

    } catch (e) {
      _mostrarError(context, 'No se pudo actualizar el favorito');
    }
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
                        id: place.id,
                        imagePath: place.imagePath,
                        title: place.title,
                        rating: place.rating,
                        isFavorite: place.isLiked,
                        onFavoriteToggle: () => _toggleLike(place.id, place.isLiked),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(id: place.id),
                        ),
                      );
                    },
                    child: PlaceCard(
                      id: place.id,
                      imagePath: place.imagePath,
                      title: place.title,
                      category: place.category,
                      rating: place.rating,
                      isFavorite: place.isFavorite,
                      location: place.location,
                      reviewCount: place.reviewCount,
                      tags: place.tags,
                    ),
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