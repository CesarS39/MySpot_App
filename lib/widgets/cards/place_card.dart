import 'package:flutter/material.dart';
import 'dart:async';
import '../../screens/place/place_detail_screen.dart';
import '../../services/place_service.dart';
import '../../services/place_notifier.dart'; // Importar el notifier

class PlaceCard extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String category;
  final double rating;
  final bool isFavorite;
  final String location;
  final int reviewCount;
  final List<String> tags;

  const PlaceCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.category,
    required this.rating,
    required this.isFavorite,
    required this.location,
    required this.reviewCount,
    required this.tags,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  late bool _isFavorite;
  bool _isProcessing = false;
  StreamSubscription<PlaceLikeUpdate>? _subscription;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    // Escuchar cambios globales de likes
    _subscription = PlaceNotifier().stream.listen((update) {
      if (update.placeId == widget.id && mounted) {
        setState(() {
          _isFavorite = update.isLiked;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final newState = await PlaceService.togglePlaceLike(widget.id);
      setState(() => _isFavorite = newState);

      // Notificar el cambio globalmente
      PlaceNotifier().notifyLikeChanged(widget.id, newState);

    } catch (e) {
      print('Error al dar like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar favorito')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(id: widget.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del lugar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),

                // Gradiente
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black12,
                        ],
                      ),
                    ),
                  ),
                ),

                // Categoría
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Botón de favorito
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: _isProcessing
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                        ),
                      )
                          : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.orange.shade600, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              widget.rating.toString(),
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.shade500, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tags
                  if (widget.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),

                  const SizedBox(height: 12),

                  // Footer
                  Row(
                    children: [
                      Text(
                        '${widget.reviewCount} reseñas',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Ver más',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}