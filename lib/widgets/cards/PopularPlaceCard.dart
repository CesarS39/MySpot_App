import 'package:flutter/material.dart';
import 'dart:async';
import '../../screens/place/place_detail_screen.dart';
import '../../services/place_notifier.dart';

class PopularPlaceCard extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final double rating;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const PopularPlaceCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.rating,
    required this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  State<PopularPlaceCard> createState() => _PopularPlaceCardState();
}

class _PopularPlaceCardState extends State<PopularPlaceCard> {
  late bool _isFavorite;
  StreamSubscription<PlaceLikeUpdate>? _subscription;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    // ✅ SOLO escuchar cambios de PlaceCard, NO del callback propio
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
  void didUpdateWidget(PopularPlaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
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
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(widget.imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradiente
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            // Botón de favorito
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onFavoriteToggle, // ✅ Solo usar el callback, sin lógica extra
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),

            // Texto inferior
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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