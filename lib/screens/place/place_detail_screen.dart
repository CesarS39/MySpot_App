import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/shared/ReviewWidget.dart';
import 'package:myspot_02/models/review.dart';


class PlaceDetailScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final double rating;
  final bool isFavorite;
  final String category;
  final String location;
  final int reviewCount;
  final List<String> tags;
  final String description;
  final List<String> galleryImages;
  final double latitude;
  final double longitude;

  const PlaceDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.isFavorite,
    required this.category,
    required this.location,
    required this.reviewCount,
    required this.tags,
    required this.description,
    required this.galleryImages,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  bool _showWriteReview = false;

  // Datos de ejemplo para las reseñas
  List<Review> _reviews = [
    Review(
      id: '1',
      userId: 'user1',
      userName: 'María González',
      userAvatar: 'https://via.placeholder.com/50',
      content: '¡Increíble experiencia! El lugar es exactamente como en las fotos. La comida estuvo deliciosa y el servicio fue excepcional. Definitivamente regresaré.',
      rating: 5.0,
      images: ['lib/images/grutas.jpg', 'lib/images/grutas.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 24,
      isLiked: true,
      isPinned: true,
      replies: [
        Review(
          id: '1-1',
          userId: 'user2',
          userName: 'Carlos Ruiz',
          userAvatar: 'https://via.placeholder.com/50',
          content: '¡Totalmente de acuerdo! Fui la semana pasada y quedé fascinado.',
          rating: null,
          images: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          likesCount: 5,
          isLiked: false,
          replies: [],
        ),
        Review(
          id: '1-2',
          userId: 'user3',
          userName: 'Ana Martínez',
          userAvatar: 'https://via.placeholder.com/50',
          content: '¿Cuál plato recomiendan más? Voy el próximo fin de semana 😍',
          rating: null,
          images: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          likesCount: 2,
          isLiked: true,
          replies: [],
        ),
      ],
    ),
    Review(
      id: '2',
      userId: 'user4',
      userName: 'Roberto Silva',
      userAvatar: 'https://via.placeholder.com/50',
      content: 'Muy buen lugar para pasar en familia. Los niños se divirtieron mucho y nosotros pudimos relajarnos. El único detalle es que puede ser un poco ruidoso en las horas pico.',
      rating: 4.0,
      images: ['lib/images/grutas.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 18,
      isLiked: false,
      replies: [
        Review(
          id: '2-1',
          userId: 'user5',
          userName: 'Laura Hernández',
          userAvatar: 'https://via.placeholder.com/50',
          content: '¿A qué hora recomiendan ir para evitar las multitudes?',
          rating: null,
          images: [],
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          likesCount: 3,
          isLiked: false,
          replies: [],
        ),
      ],
    ),
    Review(
      id: '3',
      userId: 'user6',
      userName: 'Diego Morales',
      userAvatar: 'https://via.placeholder.com/50',
      content: 'Lugar espectacular para tomar fotos. La vista es impresionante y la atención al cliente es de primera. Sin duda uno de los mejores lugares que he visitado.',
      rating: 4.8,
      images: ['lib/images/grutas.jpg', 'lib/images/grutas.jpg', 'lib/images/grutas.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      likesCount: 31,
      isLiked: true,
      replies: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  Future<void> _openInMaps() async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    final String appleMapsUrl = 'https://maps.apple.com/?q=${widget.latitude},${widget.longitude}';

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
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
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
                    itemCount: widget.galleryImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(widget.galleryImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

                  // Indicador de páginas
                  if (widget.galleryImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.galleryImages.length,
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
                                widget.category,
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
                                    '${widget.rating}',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${widget.reviewCount})',
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
                          widget.title,
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
                                widget.location,
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
                        if (widget.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.tags.map((tag) => Container(
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
                          widget.description,
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