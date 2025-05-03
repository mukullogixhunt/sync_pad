
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart'; 

@immutable 
class NoteEntity extends Equatable {
  final String id; 
  final String title;
  final String content;
  final DateTime createdAt; 
  final DateTime updatedAt; 

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, content, createdAt, updatedAt];



}