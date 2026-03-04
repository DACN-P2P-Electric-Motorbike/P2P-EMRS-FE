import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.rating,
    super.comment,
    super.userName,
    super.userAvatarUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      userName: user?['fullName'] as String?,
      userAvatarUrl: user?['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  ReviewEntity toEntity() => ReviewEntity(
    id: id,
    userId: userId,
    vehicleId: vehicleId,
    rating: rating,
    comment: comment,
    userName: userName,
    userAvatarUrl: userAvatarUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
