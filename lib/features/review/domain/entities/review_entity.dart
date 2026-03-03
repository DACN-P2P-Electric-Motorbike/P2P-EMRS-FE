import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    rating,
    comment,
    userName,
    userAvatarUrl,
    createdAt,
    updatedAt,
  ];
}
