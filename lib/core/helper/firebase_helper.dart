import 'package:budgetly/core/import_to_export.dart';

class FirebaseHelper {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  // ==========================================
  // Authentication & User Data
  // ==========================================

  static Stream<User?> get authStateChanges => auth.authStateChanges();
  static User? get currentUser => auth.currentUser;

  static Future<UserCredential?> signInWithGoogle() async {
    FirebaseLogger.request('signInWithGoogle');
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        FirebaseLogger.info('signInWithGoogle: Cancelled by user');
        return null; // Cancelled by user
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await auth.signInWithCredential(credential);
      FirebaseLogger.auth(
        'signInWithGoogle Success',
        userId: result.user?.uid,
        email: result.user?.email,
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('signInWithGoogle', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    FirebaseLogger.request('signOut');
    try {
      await googleSignIn.signOut();
      FirebaseLogger.info('signOut: Successfully signed out from GoogleSignIn');
    } catch (e, stackTrace) {
      FirebaseLogger.error('signOut', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> saveUserData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    FirebaseLogger.request('saveUserData', {'uid': uid});
    try {
      await db.collection('users').doc(uid).set(data);
      FirebaseLogger.response('saveUserData');
    } catch (e, stackTrace) {
      FirebaseLogger.error('saveUserData', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateUserData(
    String authEmail,
    Map<String, dynamic> data,
  ) async {
    FirebaseLogger.request('updateUserData', {'authEmail': authEmail});
    try {
      await db.collection('users').doc(authEmail).update(data);
      FirebaseLogger.response('updateUserData');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateUserData', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateUserPhone(String authEmail, String phone) async {
    FirebaseLogger.request('updateUserPhone', {
      'authEmail': authEmail,
      'phone': phone,
    });
    try {
      await db.collection('users').doc(authEmail).update({'phone': phone});
      FirebaseLogger.response('updateUserPhone');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateUserPhone', e, stackTrace);
      rethrow;
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
    String? authEmail,
  ) async {
    FirebaseLogger.request('getUserData', {'authEmail': authEmail});
    try {
      if (authEmail == null || authEmail.isEmpty) {
        FirebaseLogger.error('getUserData', "Invalid email");
        return Future.error("Invalid email");
      }
      final result = await db.collection('users').doc(authEmail).get();
      FirebaseLogger.response('getUserData', result.data());
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getUserData', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // Expenses
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    FirebaseLogger.request('getExpenses', {
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
    });
    try {
      final result = await db
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      FirebaseLogger.response(
        'getExpenses',
        'Found ${result.docs.length} expenses',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getExpenses', e, stackTrace);
      rethrow;
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getYearsWithExpenses(
    String userId,
  ) async {
    FirebaseLogger.request('getYearsWithExpenses', {'userId': userId});
    try {
      final result = await db
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();
      FirebaseLogger.response(
        'getYearsWithExpenses',
        'Found ${result.docs.length} expenses',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getYearsWithExpenses', e, stackTrace);
      rethrow;
    }
  }

  static Future<DocumentReference<Map<String, dynamic>>> addExpense(
    Expense expense,
  ) async {
    FirebaseLogger.request('addExpense', {'expense': expense.toFirestore()});
    try {
      final result = await db.collection('expenses').add(expense.toFirestore());
      FirebaseLogger.response(
        'addExpense',
        'Added expense with ID: ${result.id}',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('addExpense', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateExpense(String id, Expense expense) async {
    FirebaseLogger.request('updateExpense', {
      'id': id,
      'expense': expense.toFirestore(),
    });
    try {
      await db.collection('expenses').doc(id).update(expense.toFirestore());
      FirebaseLogger.response('updateExpense');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateExpense', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteExpense(String id) async {
    FirebaseLogger.request('deleteExpense', {'id': id});
    try {
      await db.collection('expenses').doc(id).delete();
      FirebaseLogger.response('deleteExpense');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteExpense', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // Budgets
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getBudgets(
    String userId,
    int year,
  ) async {
    FirebaseLogger.request('getBudgets', {'userId': userId, 'year': year});
    try {
      final result = await db
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('year', isEqualTo: year)
          .get();
      FirebaseLogger.response(
        'getBudgets',
        'Found ${result.docs.length} budgets',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getBudgets', e, stackTrace);
      rethrow;
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getBudgetForMonth(
    String userId,
    int year,
    int month,
  ) async {
    FirebaseLogger.request('getBudgetForMonth', {
      'userId': userId,
      'year': year,
      'month': month,
    });
    try {
      final result = await db
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();
      FirebaseLogger.response(
        'getBudgetForMonth',
        'Found ${result.docs.length} budgets',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getBudgetForMonth', e, stackTrace);
      rethrow;
    }
  }

  static Future<DocumentReference<Map<String, dynamic>>> addBudget(
    Map<String, dynamic> budgetData,
  ) async {
    FirebaseLogger.request('addBudget', budgetData);
    try {
      final result = await db.collection('budgets').add(budgetData);
      FirebaseLogger.response(
        'addBudget',
        'Added budget with ID: ${result.id}',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('addBudget', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateBudget(String id, int value) async {
    FirebaseLogger.request('updateBudget', {'id': id, 'value': value});
    try {
      await db.collection('budgets').doc(id).update({'budget': value});
      FirebaseLogger.response('updateBudget');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateBudget', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // Categories
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getCategories(
    String userId,
  ) async {
    FirebaseLogger.request('getCategories', {'userId': userId});
    try {
      final result = await db
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .orderBy('name')
          .get();
      FirebaseLogger.response(
        'getCategories',
        'Found ${result.docs.length} categories',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getCategories', e, stackTrace);
      rethrow;
    }
  }

  static Future<DocumentReference<Map<String, dynamic>>> addCategory(
    String name,
    String emoji,
  ) async {
    final userId = PreferenceHelper.userId;
    final categoryData = {'name': name, 'emoji': emoji, 'userId': userId};
    FirebaseLogger.request('addCategory', categoryData);
    try {
      final result = await db.collection('categories').add(categoryData);
      FirebaseLogger.response(
        'addCategory',
        'Added category with ID: ${result.id}',
      );
      return result;
    } catch (e, stackTrace) {
      FirebaseLogger.error('addCategory', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateCategory(Category category) async {
    FirebaseLogger.request('updateCategory', {
      'id': category.id,
      'categoryData': category.toFirestore(),
    });
    try {
      await db
          .collection('categories')
          .doc(category.id)
          .update(category.toFirestore());
      FirebaseLogger.response('updateCategory');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateCategory', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteCategory(String id) async {
    FirebaseLogger.request('deleteCategory', {'id': id});
    try {
      await db.collection('categories').doc(id).delete();
      FirebaseLogger.response('deleteCategory');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteCategory', e, stackTrace);
      rethrow;
    }
  }
}
