import 'package:budgetly/core/import_to_export.dart';

class FirebaseHelper {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  // ==========================================
  // MARK: Authentication & User Data
  // ==========================================

  static Stream<User?> get authStateChanges => auth.authStateChanges();
  static User? get currentUser => auth.currentUser;
  static String get currentUid {
    final uid = currentUser?.uid ?? PreferenceHelper.userId;
    if (uid.isNotEmpty) {
      PreferenceHelper.userId = uid;
    }
    return uid;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    FirebaseLogger.request('signInWithGoogle');
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        FirebaseLogger.info('signInWithGoogle: Cancelled by user');
        return null; // Cancelled by user
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
      PreferenceHelper.userId = result.user?.uid;
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

  static Future<void> saveUserData(String uid, UserInputModel data) async {
    FirebaseLogger.request('saveUserData', {'uid': uid});
    try {
      await db.collection('users').doc(uid).set(data.toJson());
      FirebaseLogger.response('saveUserData');
    } catch (e, stackTrace) {
      FirebaseLogger.error('saveUserData', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateUserLastLogin(String authEmail) async {
    FirebaseLogger.request('updateUserLastLogin', {'authEmail': authEmail});
    try {
      await db.collection('users').doc(authEmail).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      FirebaseLogger.response('updateUserLastLogin');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateUserLastLogin', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateUserPhone(String authEmail, String phone) async {
    FirebaseLogger.request('updateUserPhone', {'authEmail': authEmail, 'phone': phone});
    try {
      await db.collection('users').doc(authEmail).update({'phone': phone});
      FirebaseLogger.response('updateUserPhone');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateUserPhone', e, stackTrace);
      rethrow;
    }
  }

  static Future<UserModel?> getUserData(String? authEmail) async {
    FirebaseLogger.request('getUserData', {'authEmail': authEmail});
    try {
      if (authEmail == null || authEmail.isEmpty) {
        FirebaseLogger.error('getUserData', "Invalid email");
        return Future.error("Invalid email");
      }
      final result = await db.collection('users').doc(authEmail).get();
      FirebaseLogger.response('getUserData', result.data());
      final data = result.data();
      if (data == null) return null;
      data['uid'] = currentUser?.uid ?? '';
      return UserModel.fromJson(data);
    } catch (e, stackTrace) {
      FirebaseLogger.error('getUserData', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteAccount() async {
    FirebaseLogger.request('deleteAccount');
    try {
      final email = currentUser?.email;
      if (email != null) {
        await db.collection('users').doc(email).delete();
      }
      await currentUser?.delete();
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      FirebaseLogger.response('deleteAccount');
    } on FirebaseAuthException catch (e, stackTrace) {
      if (e.code == 'requires-recent-login') {
        await reauthenticate(e, stackTrace);
      } else {
        FirebaseLogger.error('deleteAccount', e, stackTrace);
        rethrow;
      }
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteAccount', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> reauthenticate(FirebaseAuthException e, StackTrace stackTrace) async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await currentUser?.reauthenticateWithCredential(credential);
      final email = currentUser?.email;
      if (email != null) {
        await db.collection('users').doc(email).delete();
      }
      await currentUser?.delete();
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      FirebaseLogger.response('deleteAccount');
    } else {
      FirebaseLogger.error('deleteAccount: Re-authentication cancelled by user', e, stackTrace);
      throw Exception('Please re-authenticate to delete your account.');
    }
  }

  // ==========================================
  // MARK: Expenses
  // ==========================================

  static Future<List<Expense>> getExpenses(DateTime startDate, DateTime endDate) async {
    FirebaseLogger.request('getExpenses', {
      'userId': currentUid,
      'startDate': startDate,
      'endDate': endDate,
    });
    try {
      final result = await db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      FirebaseLogger.response('getExpenses', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => Expense.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getExpenses', e, stackTrace);
      rethrow;
    }
  }

  static Future<List<Expense>> getYearsWithExpenses() async {
    FirebaseLogger.request('getYearsWithExpenses', {'userId': currentUid});
    try {
      final result = await db.collection('expenses').where('userId', isEqualTo: currentUid).get();
      FirebaseLogger.response('getYearsWithExpenses', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => Expense.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getYearsWithExpenses', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addExpense(Expense expense) async {
    FirebaseLogger.request('addExpense', {'expense': expense.toFirestore()});
    try {
      await db.collection('expenses').add(expense.toFirestore());
      FirebaseLogger.response('addExpense');
    } catch (e, stackTrace) {
      FirebaseLogger.error('addExpense', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateExpense(String id, Expense expense) async {
    FirebaseLogger.request('updateExpense', {'id': id, 'expense': expense.toFirestore()});
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

  static Future<void> deleteUserExpenses() async {
    FirebaseLogger.request('deleteUserExpenses', {'userId': currentUid});
    try {
      final result = await db.collection('expenses').where('userId', isEqualTo: currentUid).get();
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
      FirebaseLogger.response('deleteUserExpenses', 'Deleted ${result.docs.length} expenses');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteUserExpenses', e, stackTrace);
      rethrow;
    }
  }

  static Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    FirebaseLogger.request('getExpensesByCategory', {
      'userId': currentUid,
      'categoryId': categoryId,
    });
    try {
      final result = await db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true)
          .get();
      FirebaseLogger.response('getExpensesByCategory', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => Expense.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getExpensesByCategory', e, stackTrace);
      rethrow;
    }
  }

  static Future<double> getCategoryTotal(String categoryId) async {
    FirebaseLogger.request('getCategoryTotal', {'categoryId': categoryId});
    try {
      final query = db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('categoryId', isEqualTo: categoryId);

      final aggregateSnapshot = await query.aggregate(sum('price')).get();
      final total = aggregateSnapshot.getSum('price') ?? 0.0;
      FirebaseLogger.response('getCategoryTotal', total);
      return total;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getCategoryTotal', e, stackTrace);
      rethrow;
    }
  }

  static Future<int> getCategoryTransactionCount(String categoryId) async {
    FirebaseLogger.request('getCategoryTransactionCount', {'categoryId': categoryId});
    try {
      final query = db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('categoryId', isEqualTo: categoryId);

      final aggregateSnapshot = await query.count().get();
      final count = aggregateSnapshot.count ?? 0;
      FirebaseLogger.response('getCategoryTransactionCount', count);
      return count;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getCategoryTransactionCount', e, stackTrace);
      rethrow;
    }
  }

  static Future<double> getTotalExpenseForMonth(int year, int month) async {
    FirebaseLogger.request('getTotalExpenseForMonth', {'year': year, 'month': month});
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));

      final query = db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final aggregateSnapshot = await query.aggregate(sum('price')).get();
      final total = aggregateSnapshot.getSum('price') ?? 0.0;
      FirebaseLogger.response('getTotalExpenseForMonth', total);
      return total;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getTotalExpenseForMonth', e, stackTrace);
      rethrow;
    }
  }

  static Future<double> getTotalExpenseForYear(int year) async {
    FirebaseLogger.request('getTotalExpenseForYear', {'year': year});
    try {
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      final query = db
          .collection('expenses')
          .where('userId', isEqualTo: currentUid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      final aggregateSnapshot = await query.aggregate(sum('price')).get();
      final total = aggregateSnapshot.getSum('price') ?? 0.0;
      FirebaseLogger.response('getTotalExpenseForYear', total);
      return total;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getTotalExpenseForYear', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // MARK:Budgets
  // ==========================================

  static Future<List<MonthBudget>> getBudgets(int year) async {
    FirebaseLogger.request('getBudgets', {'userId': currentUid, 'year': year});
    try {
      final result = await db
          .collection('budgets')
          .where('userId', isEqualTo: currentUid)
          .where('year', isEqualTo: year)
          .get();
      FirebaseLogger.response('getBudgets', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => MonthBudget.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getBudgets', e, stackTrace);
      rethrow;
    }
  }

  static Future<MonthBudget?> getBudgetForMonth(int year, int month) async {
    FirebaseLogger.request('getBudgetForMonth', {
      'userId': currentUid,
      'year': year,
      'month': month,
    });
    try {
      final result = await db
          .collection('budgets')
          .where('userId', isEqualTo: currentUid)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();
      FirebaseLogger.response('getBudgetForMonth', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      if (result.docs.isEmpty) return null;
      return MonthBudget.fromFirestore(result.docs.first);
    } catch (e, stackTrace) {
      FirebaseLogger.error('getBudgetForMonth', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addBudget(Map<String, dynamic> budgetData) async {
    FirebaseLogger.request('addBudget', budgetData);
    try {
      await db.collection('budgets').add(budgetData);
      FirebaseLogger.response('addBudget');
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

  static Future<void> deleteUserBudgets() async {
    FirebaseLogger.request('deleteUserBudgets', {'userId': currentUid});
    try {
      final result = await db.collection('budgets').where('userId', isEqualTo: currentUid).get();
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
      FirebaseLogger.response('deleteUserBudgets', 'Deleted ${result.docs.length} budgets');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteUserBudgets', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // MARK: Categories
  // ==========================================

  static Future<List<Category>> getCategories() async {
    FirebaseLogger.request('getCategories', {'userId': currentUid});
    try {
      final result = await db
          .collection('categories')
          .where('userId', isEqualTo: currentUid)
          .orderBy('name')
          .get();
      FirebaseLogger.response('getCategories', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => Category.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getCategories', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addCategory(String name, String emoji) async {
    final categoryData = {'name': name, 'emoji': emoji, 'userId': currentUid};
    FirebaseLogger.request('addCategory', categoryData);
    try {
      await db.collection('categories').add(categoryData);
      FirebaseLogger.response('addCategory');
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
      await db.collection('categories').doc(category.id).update(category.toFirestore());
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

  static Future<void> deleteUserCategories() async {
    FirebaseLogger.request('deleteUserCategories', {'userId': currentUid});
    try {
      final result = await db.collection('categories').where('userId', isEqualTo: currentUid).get();
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
      FirebaseLogger.response('deleteUserCategories', 'Deleted ${result.docs.length} categories');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteUserCategories', e, stackTrace);
      rethrow;
    }
  }
  // ==========================================
  // MARK: Sheets
  // ==========================================

  static Future<List<Sheet>> getSheets() async {
    FirebaseLogger.request('getSheets', {'userId': PreferenceHelper.userId});
    try {
      final sheetsSnap = await db
          .collection('sheets')
          .where('userId', isEqualTo: PreferenceHelper.userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Sheet> sheets = [];
      for (var sheetDoc in sheetsSnap.docs) {
        final recordsSnap = await sheetDoc.reference.collection('records').get();
        final records = recordsSnap.docs.map((r) => SheetRecord.fromFirestore(r)).toList();
        sheets.add(Sheet.fromFirestore(sheetDoc, records));
      }
      FirebaseLogger.response('getSheets', {
        'count': sheets.length,
        'data': sheets.map((d) => d.toFirestore()).toList(),
      });
      return sheets;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getSheets', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addSheet(Map<String, dynamic> sheetData) async {
    FirebaseLogger.request('addSheet', sheetData);
    try {
      await db.collection('sheets').add(sheetData);
      FirebaseLogger.response('addSheet');
    } catch (e, stackTrace) {
      FirebaseLogger.error('addSheet', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateSheet(String sheetId, Map<String, dynamic> sheetData) async {
    FirebaseLogger.request('updateSheet', {'sheetId': sheetId, 'sheetData': sheetData});
    try {
      await db.collection('sheets').doc(sheetId).update(sheetData);
      FirebaseLogger.response('updateSheet');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateSheet', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteSheet(String sheetId) async {
    FirebaseLogger.request('deleteSheet', {'sheetId': sheetId});
    try {
      final records = await db.collection('sheets').doc(sheetId).collection('records').get();

      final batch = db.batch();
      for (final doc in records.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(db.collection('sheets').doc(sheetId));
      await batch.commit();
      FirebaseLogger.response('deleteSheet');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteSheet', e, stackTrace);
      rethrow;
    }
  }

  // ==========================================
  // MARK: Sheet Records (subcollection inside sheets)
  // ==========================================

  static Future<List<SheetRecord>> getRecords(String sheetId) async {
    FirebaseLogger.request('getRecords', {'sheetId': sheetId});
    try {
      final result = await db
          .collection('sheets')
          .doc(sheetId)
          .collection('records')
          .orderBy('date', descending: true)
          .get();
      FirebaseLogger.response('getRecords', {
        'count': result.docs.length,
        'data': result.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      });
      return result.docs.map((d) => SheetRecord.fromFirestore(d)).toList();
    } catch (e, stackTrace) {
      FirebaseLogger.error('getRecords', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addRecord(String sheetId, Map<String, dynamic> record) async {
    FirebaseLogger.request('addRecord', {'sheetId': sheetId, 'record': record});
    try {
      await db.collection('sheets').doc(sheetId).collection('records').add(record);
      FirebaseLogger.response('addRecord');
    } catch (e, stackTrace) {
      FirebaseLogger.error('addRecord', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> updateRecord(
    String sheetId,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    FirebaseLogger.request('updateRecord', {
      'sheetId': sheetId,
      'recordId': recordId,
      'data': data,
    });
    try {
      await db.collection('sheets').doc(sheetId).collection('records').doc(recordId).update(data);
      FirebaseLogger.response('updateRecord');
    } catch (e, stackTrace) {
      FirebaseLogger.error('updateRecord', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> deleteRecord(String sheetId, String recordId) async {
    FirebaseLogger.request('deleteRecord', {'sheetId': sheetId, 'recordId': recordId});
    try {
      await db.collection('sheets').doc(sheetId).collection('records').doc(recordId).delete();
      FirebaseLogger.response('deleteRecord');
    } catch (e, stackTrace) {
      FirebaseLogger.error('deleteRecord', e, stackTrace);
      rethrow;
    }
  }

  static Future<double> getSheetBalance(String sheetId) async {
    FirebaseLogger.request('getSheetBalance', {'sheetId': sheetId});
    try {
      final query = db.collection('sheets').doc(sheetId).collection('records');
      final income = await query
          .where('type', isEqualTo: 'income')
          .aggregate(sum('amount'))
          .get()
          .then((snapshot) => snapshot.getSum('amount') ?? 0.0);

      final expense = await query
          .where('type', isEqualTo: 'expense')
          .aggregate(sum('amount'))
          .get()
          .then((snapshot) => snapshot.getSum('amount') ?? 0.0);

      return income - expense;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getSheetBalance', e, stackTrace);
      rethrow;
    }
  }

  static Future<double> getTotalSheetsBalance() async {
    FirebaseLogger.request('getTotalSheetsBalance', {'userId': PreferenceHelper.userId});
    try {
      final sheets = await getSheets();
      double totalBalance = 0.0;

      for (var sheet in sheets) {
        for (var record in sheet.records) {
          if (record.isIncome) {
            totalBalance += record.amount;
          } else if (record.isExpense) {
            totalBalance -= record.amount;
          }
        }
      }

      FirebaseLogger.response('getTotalSheetsBalance', totalBalance);
      return totalBalance;
    } catch (e, stackTrace) {
      FirebaseLogger.error('getTotalSheetsBalance', e, stackTrace);
      rethrow;
    }
  }
}
