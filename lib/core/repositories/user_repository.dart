import 'package:budgetly/core/import_to_export.dart';

abstract class UserRepository {
  Future<UserModel?> getUserData(String? email);
  Future<void> saveUserData(String uid, UserInputModel data);
  Future<void> updateUserLastLogin(String email);
  Future<void> updateUserPhone(String email, String phone);
  Future<void> deleteAccount();
}

class FirebaseUserRepository implements UserRepository {
  @override
  Future<UserModel?> getUserData(String? email) {
    return FirebaseHelper.getUserData(email);
  }

  @override
  Future<void> saveUserData(String uid, UserInputModel data) {
    return FirebaseHelper.saveUserData(uid, data);
  }

  @override
  Future<void> updateUserLastLogin(String email) {
    return FirebaseHelper.updateUserLastLogin(email);
  }

  @override
  Future<void> updateUserPhone(String email, String phone) {
    return FirebaseHelper.updateUserPhone(email, phone);
  }

  @override
  Future<void> deleteAccount() {
    return FirebaseHelper.deleteAccount();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});
