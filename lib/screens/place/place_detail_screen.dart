
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/shared/ReviewWidget.dart';
import 'package:myspot_02/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/place_service.dart';
import '../../services/place_notifier.dart'; // ✅ Importar el notifier

class PlaceDetailScreen extends StatefulWidget {
  final String id;
  const PlaceDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isProcessingLike = false; // ✅ Estado para el procesamiento del like
  final ScrollController _scrollController = ScrollController();
  bool _showWriteReview = false;

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  // Estado para los datos del lugar
  String title = '';
  String imagePath = '';
  double rating = 0.0;
  bool isFavorite = false;
  String category = '';
  String location = '';
  int reviewCount = 0;
  List<String> tags = [];
  String description = '';
  List<String> galleryImages = [];
  double latitude = 0.0;
  double longitude = 0.0;

  // TODO: Reemplaza esto con tu método real para obtener el JWT del usuario autenticado
  String get jwtToken => "YOUR_JWT_TOKEN";

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    try {
      final data = await PlaceService.fetchPlaceDetails(widget.id);
      setState(() {
        title = data["title"] ?? '';
        imagePath = data["main_image_url"] ?? '';
        rating = (data["rating"] ?? 0).toDouble();
        isFavorite = data["isFavorite"] ?? false;
        _isFavorite = isFavorite; // ✅ Sincronizar ambos estados
        category = data["category"] ?? '';
        location = data["location"] ?? '';
        reviewCount = data["reviewCount"] ?? 0;
        tags = List<String>.from(data["tags"] ?? []);
        description = data["description"] ?? '';
        galleryImages = List<String>.from(data["galleryImages"] ?? []);
        latitude = (data["latitude"] ?? 0.0).toDouble();
        longitude = (data["longitude"] ?? 0.0).toDouble();
      });

      await _loadReviews();
    } catch (e) {
      print('Error al cargar detalles del lugar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar la información del lugar')),
      );
    }
  }

  // ✅ Nueva función para manejar el toggle de like
  Future<void> _toggleFavorite() async {
    if (_isProcessingLike) return;

    setState(() => _isProcessingLike = true);

    try {
      final newState = await PlaceService.togglePlaceLike(widget.id);

      setState(() {
        _isFavorite = newState;
        isFavorite = newState;
      });

      // ✅ Notificar el cambio globalmente para sincronizar con otras pantallas
      PlaceNotifier().notifyLikeChanged(widget.id, newState);

      // ✅ Mostrar feedback al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Agregado a favoritos' : 'Removido de favoritos'),
          duration: const Duration(seconds: 1),
          backgroundColor: newState ? Colors.green : Colors.grey,
        ),
      );

    } catch (e) {
      print('Error al actualizar favorito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessingLike = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final data = await PlaceService.fetchPlaceReviews(widget.id);

      if (data is Map<String, dynamic> && data['results'] is List) {
        final List<dynamic> results = data['results'];

        setState(() {
          _reviews = results.map((r) => Review.fromJson(r)).toList();
          _isLoadingReviews = false;
        });
      } else {
        print('Formato inesperado en respuesta de reviews: $data');
        setState(() => _isLoadingReviews = false);
      }
    } catch (e) {
      print('Error al cargar reseñas: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _openInMaps() async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
          await launchUrl(Uri.parse(appleMapsUrl));
        } else {
          await launchUrl(Uri.parse(googleMapsUrl));
        }
      } else {
        await launchUrl(Uri.parse(googleMapsUrl));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la aplicación de mapas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar con galería de imágenes
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isProcessingLike
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                    ),
                  )
                      : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: _isProcessingLike ? null : _toggleFavorite, // ✅ Usar la nueva función
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Galería de imágenes
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: galleryImages.isNotEmpty
                                ? NetworkImage(galleryImages[index])
                                : const AssetImage('assets/placeholder.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

                  // Indicador de páginas
                  if (galleryImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          galleryImages.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Gradiente para mejor legibilidad
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categoría y rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.orange.shade600, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '($reviewCount)',
                                    style: TextStyle(
                                      color: Colors.orange.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Título
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Ubicación con botón de mapas
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey.shade500, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _openInMaps,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.map, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ver en mapa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tags
                        if (tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),

                        const SizedBox(height: 24),

                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Header de reseñas
                        Row(
                          children: [
                            const Text(
                              'Reseñas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showWriteReview = !_showWriteReview;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.add, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Escribir reseña',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Formulario para escribir reseña (expandible)
                  if (_showWriteReview)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: const WriteReviewForm(),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Lista de reseñas
          if (_isLoadingReviews)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final review = _reviews[index];
                  return ReviewWidget(
                    review: review,
                    onLike: (reviewId) {
                      // TODO: Implementar lógica de like
                    },
                    onReply: (reviewId) {
                      // TODO: Implementar lógica de respuesta
                    },
                  );
                },
                childCount: _reviews.length,
              ),
            ),

          // Espaciado final
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

// Widget para escribir nueva reseña
class WriteReviewForm extends StatefulWidget {
  const WriteReviewForm({super.key});

  @override
  State<WriteReviewForm> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends State<WriteReviewForm> {
  double _rating = 5.0;
  final TextEditingController _textController = TextEditingController();
  List<String> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escribe tu reseña',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Selector de rating
        Row(
          children: [
            const Text('Calificación: ', style: TextStyle(fontWeight: FontWeight.w500)),
            ...List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 24,
                ),
              );
            }),
            const SizedBox(width: 8),
            Text('$_rating/5', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),

        const SizedBox(height: 12),

        // Campo de texto
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Comparte tu experiencia...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botones de acción
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Implementar selección de imágenes
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Fotos', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                      _rating = 5.0;
                    });
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar envío de reseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reseña publicada exitosamente')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Publicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}