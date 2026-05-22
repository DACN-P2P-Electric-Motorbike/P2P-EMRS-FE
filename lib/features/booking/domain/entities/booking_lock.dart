import 'package:equatable/equatable.dart';

class BookingLock extends Equatable {
  final String id;
  final DateTime expiresAt;

  const BookingLock({required this.id, required this.expiresAt});

  @override
  List<Object?> get props => [id, expiresAt];
}
