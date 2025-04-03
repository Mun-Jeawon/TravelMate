class Review {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final double rating;
  final DateTime createdAt;
  final String? imageUrl;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.imageUrl,
  });
}

