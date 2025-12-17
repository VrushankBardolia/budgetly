import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final DateTime date;
  final double price;
  final String categoryId;
  final String detail;
  final String userId;

  Expense({
    required this.id,
    required this.date,
    required this.price,
    required this.categoryId,
    required this.detail,
    required this.userId,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      price: (data['price'] as num).toDouble(),
      categoryId: data['categoryId'] as String,
      detail: data['detail'] as String,
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'price': price,
      'categoryId': categoryId,
      'detail': detail,
      'userId': userId,
    };
  }
}

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
    return {
      'name': name,
      'emoji': emoji,
      'userId': userId,
    };
  }
}

class MonthBudget {
  final String id;
  final int year;
  final int month;
  final double budget;
  final String userId;

  MonthBudget({
    required this.id,
    required this.year,
    required this.month,
    required this.budget,
    required this.userId,
  });

  factory MonthBudget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonthBudget(
      id: doc.id,
      year: data['year'] as int,
      month: data['month'] as int,
      budget: (data['budget'] as num).toDouble(),
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'year': year,
      'month': month,
      'budget': budget,
      'userId': userId,
    };
  }
}