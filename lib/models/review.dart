class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final double? rating;
  final List<String> images;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;
  final List<Review> replies;
  final bool isPinned;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.rating,
    required this.images,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    required this.replies,
    this.isPinned = false,
  });
}