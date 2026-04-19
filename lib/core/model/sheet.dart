import 'package:cloud_firestore/cloud_firestore.dart';

class Sheet {
  final String id;
  final String userId;
  final String name;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sheet({
    required this.id,
    required this.userId,
    required this.name,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sheet.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Sheet(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      // Removed the records parsing logic entirely
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'year': year,
    // Removed records mapping
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
