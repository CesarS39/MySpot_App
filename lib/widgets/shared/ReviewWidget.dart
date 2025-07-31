import 'package:flutter/material.dart';
import 'package:myspot_02/models/review.dart';

class ReviewWidget extends StatefulWidget {
  final Review review;
  final Function(String) onLike;
  final Function(String) onReply;
  final bool isReply;
  final int depth;

  const ReviewWidget({
    super.key,
    required this.review,
    required this.onLike,
    required this.onReply,
    this.isReply = false,
    this.depth = 0,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> with TickerProviderStateMixin {
  bool _showReplies = false;
  bool _showReplyForm = false;
  final TextEditingController _replyController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 14);
        } else if (index < rating && rating - index >= 0.5) {
          return const Icon(Icons.star_half, color: Colors.orange, size: 14);
        } else {
          return Icon(Icons.star_border, color: Colors.grey.shade400, size: 14);
        }
      }),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: images.length == 1 ? 200 : 120,
      child: images.length == 1
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(images[0]),
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < images.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftPadding = widget.depth * 20.0 + 20.0;
    final showConnector = widget.isReply && widget.depth > 0;

    return Container(
      margin: EdgeInsets.only(
        left: widget.isReply ? 0 : 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conector visual para respuestas
          if (showConnector)
            Container(
              width: 2,
              height: 60,
              margin: const EdgeInsets.only(right: 12, top: 25),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),

          // Avatar del usuario
          Container(
            width: widget.isReply ? 32 : 40,
            height: widget.isReply ? 32 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: const DecorationImage(
                image: AssetImage('lib/images/grutas.jpg'), // Placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Contenido de la reseña
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de la reseña
                  Row(
                    children: [
                      // Nombre del usuario
                      Text(
                        widget.review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Rating (solo para reseñas principales)
                      if (widget.review.rating != null) ...[
                        _buildStarRating(widget.review.rating!),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.review.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Tiempo
                      Text(
                        _getTimeAgo(widget.review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Contenido de la reseña
                  Text(
                    widget.review.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  // Galería de imágenes
                  _buildImageGallery(widget.review.images),

                  const SizedBox(height: 12),

                  // Botones de acción
                  Row(
                    children: [
                      // Botón de like
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.review.isLiked = !widget.review.isLiked;
                            if (widget.review.isLiked) {
                              widget.review.likesCount++;
                            } else {
                              widget.review.likesCount--;
                            }
                          });
                          widget.onLike(widget.review.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.review.isLiked
                                ? Colors.red.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.review.isLiked
                                  ? Colors.red.shade200
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.review.isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: widget.review.isLiked ? Colors.red : Colors.grey.shade600,
                              ),
                              if (widget.review.likesCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.review.likesCount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.review.isLiked ? Colors.red : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Botón de responder
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showReplyForm = !_showReplyForm;
                            if (_showReplyForm) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Responder',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Botón para mostrar/ocultar respuestas
                      if (widget.review.replies.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showReplies = !_showReplies;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.review.replies.length} respuesta${widget.review.replies.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showReplies ? Icons.expand_less : Icons.expand_more,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Formulario de respuesta (expandible)
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _replyController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Escribe tu respuesta...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implementar selección de imágenes
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.camera_alt, size: 14, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text('Foto', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                                        _showReplyForm = false;
                                        _replyController.clear();
                                        _animationController.reverse();
                                      });
                                    },
                                    child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 4),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implementar envío de respuesta
                                      setState(() {
                                        _showReplyForm = false;
                                        _replyController.clear();
                                        _animationController.reverse();
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Respuesta publicada'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                    child: const Text(
                                      'Responder',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar las respuestas anidadas
class RepliesSection extends StatelessWidget {
  final List<Review> replies;
  final Function(String) onLike;
  final Function(String) onReply;
  final int depth;

  const RepliesSection({
    super.key,
    required this.replies,
    required this.onLike,
    required this.onReply,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 8),
      child: Column(
        children: replies.map((reply) => ReviewWidget(
          review: reply,
          onLike: onLike,
          onReply: onReply,
          isReply: true,
          depth: depth + 1,
        )).toList(),
      ),
    );
  }
}

// Extensión del widget principal para incluir respuestas
class ReviewWithReplies extends StatefulWidget {
  final Review review;
  final Function(String) onLike;
  final Function(String) onReply;

  const ReviewWithReplies({
    super.key,
    required this.review,
    required this.onLike,
    required this.onReply,
  });

  @override
  State<ReviewWithReplies> createState() => _ReviewWithRepliesState();
}

class _ReviewWithRepliesState extends State<ReviewWithReplies> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reseña principal
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('lib/images/grutas.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con nombre, rating y tiempo
                      Row(
                        children: [
                          Text(
                            widget.review.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),

                          if (widget.review.rating != null) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.review.rating!.floor() ? Icons.star : Icons.star_border,
                                  color: Colors.orange,
                                  size: 14,
                                );
                              }),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.review.rating}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],

                          const Spacer(),

                          Text(
                            _getTimeAgo(widget.review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Contenido
                      Text(
                        widget.review.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      // Imágenes
                      if (widget.review.images.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          height: widget.review.images.length == 1 ? 200 : 120,
                          child: widget.review.images.length == 1
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.review.images[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                              : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.review.images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                margin: EdgeInsets.only(
                                  right: index < widget.review.images.length - 1 ? 8 : 0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(widget.review.images[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Botones de acción
                      Row(
                        children: [
                          // Like
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.review.isLiked = !widget.review.isLiked;
                                if (widget.review.isLiked) {
                                  widget.review.likesCount++;
                                } else {
                                  widget.review.likesCount--;
                                }
                              });
                              widget.onLike(widget.review.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.review.isLiked ? Colors.red.shade50 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.review.isLiked ? Colors.red.shade200 : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.review.isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 16,
                                    color: widget.review.isLiked ? Colors.red : Colors.grey.shade600,
                                  ),
                                  if (widget.review.likesCount > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.review.likesCount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: widget.review.isLiked ? Colors.red : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Responder
                          GestureDetector(
                            onTap: () => widget.onReply(widget.review.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.reply, size: 16, color: Colors.blue.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Responder',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Ver respuestas
                          if (widget.review.replies.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showReplies = !_showReplies;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${widget.review.replies.length} respuesta${widget.review.replies.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showReplies ? Icons.expand_less : Icons.expand_more,
                                      size: 16,
                                      color: Colors.grey.shade600,
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
              ),
            ],
          ),
        ),

        // Respuestas anidadas
        if (_showReplies && widget.review.replies.isNotEmpty)
          RepliesSection(
            replies: widget.review.replies,
            onLike: widget.onLike,
            onReply: widget.onReply,
            depth: 0,
          ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}