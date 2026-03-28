import 'package:budgetly/core/import_to_export.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isGoogle;
  final DateTime? createdAt;

  UserModel({required this.uid, required this.name, required this.email, required this.phone, this.isGoogle = false, this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] is Timestamp) {
      parsedDate = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedDate = DateTime.tryParse(json['createdAt']);
    } else if (json['createdAt'] is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
    }

    return UserModel(
      uid: json['uid'] ?? json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isGoogle: json['isGoogle'] ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'email': email, 'phone': phone, 'isGoogle': isGoogle, 'createdAt': createdAt?.toIso8601String()};
  }

  UserModel copyWith({String? uid, String? name, String? email, String? phone, bool? isGoogle, DateTime? createdAt, List<String>? fcmTokens}) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isGoogle: isGoogle ?? this.isGoogle,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
