import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String emoji;
  final String userId;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.userId,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] as String,
      emoji: data['emoji'] as String,
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'emoji': emoji, 'userId': userId};
  }
}
