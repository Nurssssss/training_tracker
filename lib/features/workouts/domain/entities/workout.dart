import 'package:equatable/equatable.dart';

class Workout extends Equatable {
  const Workout({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String userId;
  final String title;
  final String? note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, title, note, createdAt];
}
