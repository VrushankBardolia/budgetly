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
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // Cancelled by user

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    return await auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await googleSignIn.signOut();
  }

  static Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await db.collection('users').doc(uid).set(data);
  }

  static Future<void> updateUserData(String authEmail, Map<String, dynamic> data) async {
    await db.collection('users').doc(authEmail).update(data);
  }

  static Future<void> updateUserPhone(String authEmail, String phone) async {
    await db.collection('users').doc(authEmail).update({'phone': phone});
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String? authEmail) async {
    if (authEmail == null || authEmail.isEmpty) return Future.error("Invalid email");
    return await db.collection('users').doc(authEmail).get();
  }

  // ==========================================
  // Expenses
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getExpenses(String userId, DateTime startDate, DateTime endDate) async {
    return await db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getYearsWithExpenses(String userId) async {
    return await db.collection('expenses').where('userId', isEqualTo: userId).get();
  }

  static Future<DocumentReference<Map<String, dynamic>>> addExpense(Expense expense) async {
    return await db.collection('expenses').add(expense.toFirestore());
  }

  static Future<void> updateExpense(String id, Expense expense) async {
    await db.collection('expenses').doc(id).update(expense.toFirestore());
  }

  static Future<void> deleteExpense(String id) async {
    await db.collection('expenses').doc(id).delete();
  }

  // ==========================================
  // Budgets
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getBudgets(String userId, int year) async {
    return await db.collection('budgets').where('userId', isEqualTo: userId).where('year', isEqualTo: year).get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getBudgetForMonth(String userId, int year, int month) async {
    return await db.collection('budgets').where('userId', isEqualTo: userId).where('year', isEqualTo: year).where('month', isEqualTo: month).get();
  }

  static Future<DocumentReference<Map<String, dynamic>>> addBudget(Map<String, dynamic> budgetData) async {
    return await db.collection('budgets').add(budgetData);
  }

  static Future<void> updateBudget(String id, int value) async {
    await db.collection('budgets').doc(id).update({'budget': value});
  }

  // ==========================================
  // Categories
  // ==========================================

  static Future<QuerySnapshot<Map<String, dynamic>>> getCategories(String userId) async {
    return await db.collection('categories').where('userId', isEqualTo: userId).orderBy('name').get();
  }

  static Future<DocumentReference<Map<String, dynamic>>> addCategory(Map<String, dynamic> categoryData) async {
    return await db.collection('categories').add(categoryData);
  }

  static Future<void> updateCategory(String id, Map<String, dynamic> categoryData) async {
    await db.collection('categories').doc(id).update(categoryData);
  }

  static Future<void> deleteCategory(String id) async {
    await db.collection('categories').doc(id).delete();
  }
}
