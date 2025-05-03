import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:sync_pad/features/notes/domain/entities/note_entity.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends NoteEntity with HiveObjectMixin {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String title;

  @HiveField(2)
  @override
  final String content;

  @HiveField(3)
  @override
  final DateTime createdAt;

  @HiveField(4)
  @override
  final DateTime updatedAt;

  @HiveField(5)
  final bool isSynced;

  @HiveField(6)
  final bool isDeleted;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  }) : super(
         id: id,
         title: title,
         content: content,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory NoteModel.create({required String title, required String content}) {
    final now = DateTime.now();
    return NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      isDeleted: false,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    final bool contentChanged =
        (title != null && title != this.title) ||
        (content != null && content != this.content);
    final bool statusChanged =
        (isDeleted != null && isDeleted != this.isDeleted);

    final bool needsSyncUpdate = contentChanged || statusChanged;

    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),

      isSynced: needsSyncUpdate ? false : (isSynced ?? this.isSynced),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime readTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) return timestamp.toDate();

      return DateTime.now();
    }

    return NoteModel(
      id: doc.id,

      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: readTimestamp(data['createdAt']),
      updatedAt: readTimestamp(data['updatedAt']),
      isSynced: true,

      isDeleted: false,
    );
  }

  factory NoteModel.fromEntity(NoteEntity entity) {
    if (entity is NoteModel) return entity;

    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,

      isSynced: false,
      isDeleted: false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdAt,
    updatedAt,
    isSynced,
    isDeleted,
  ];

  @override
  bool get stringify => true;
}
