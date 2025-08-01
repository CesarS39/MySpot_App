class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final double? rating;
  final List<String> images;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<Review> replies;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.rating,
    required this.images,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    required this.replies,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json["id"],
      userId: json["userId"],
      userName: json["userName"],
      userAvatar: json["userAvatar"],
      content: json["content"],
      rating: json["rating"]?.toDouble(),
      images: List<String>.from(json["images"] ?? []),
      createdAt: DateTime.parse(json["createdAt"]),
      likesCount: json["likesCount"] ?? 0,
      isLiked: json["isLiked"] ?? false,
      replies: (json["replies"] as List<dynamic>? ?? [])
          .map((reply) => Review.fromJson(reply))
          .toList(),
    );
  }
}