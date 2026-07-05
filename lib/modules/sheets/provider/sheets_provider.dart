import 'package:budgetly/core/import_to_export.dart';

class SheetsProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  List<Sheet> sheets = [];
  Map<String, double> sheetBalances = {};
  bool isLoading = true;

  SheetsProvider(this.ref) {
    loadSheets();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> loadSheets({bool isRefresh = false}) async {
    final user = FirebaseHelper.currentUser;
    if (user == null) return;

    if (!isRefresh) {
      isLoading = true;
      notifyListeners();
    }
    try {
      final result = await FirebaseHelper.getSheets();
      sheets = result;
      await _fetchBalance();
    } finally {
      if (!isRefresh) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _fetchBalance() async {
    try {
      final newBalances = <String, double>{};
      for (var sheet in sheets) {
        double balance = 0;
        for (var record in sheet.records) {
          if (record.type == RecordType.income) {
            balance += record.amount;
          } else if (record.type == RecordType.expense) {
            balance -= record.amount;
          }
        }
        newBalances[sheet.id] = balance;
      }
      sheetBalances = newBalances;
    } catch (e) {
      debugPrint(e.toString());
      final newBalances = <String, double>{};
      for (var sheet in sheets) {
        newBalances[sheet.id] = 0.0;
      }
      sheetBalances = newBalances;
    }
    notifyListeners();
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<void> showCreateSheetDialog() async {
    final nameCtrl = TextEditingController();
    int selectedYear = DateTime.now().year;

    await dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('New Sheet', textAlign: TextAlign.center, style: boldText(14)),
          content: TextField(
            controller: nameCtrl,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Sheet name  (e.g. 2025 Finances)',
              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brand, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: appRouter.pop,
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                await _createSheet(name, selectedYear);
                appRouter.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Create', style: semiBoldText(14)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSheet(String name, int year) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    await FirebaseHelper.addSheet({
      'userId': userId,
      'name': name,
      'year': year,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'records': [],
    });

    await loadSheets(isRefresh: true);
  }

  // ─── Rename ───────────────────────────────────────────────────────────────

  Future<void> showRenameDialog(Sheet sheet) async {
    final nameCtrl = TextEditingController(text: sheet.name);

    await dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Sheet', style: boldText(14)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brand, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: appRouter.pop,
            child: Text('Cancel', style: regularText(14, color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              await FirebaseHelper.updateSheet(sheet.id, {
                'name': name,
                'updatedAt': Timestamp.fromDate(DateTime.now()),
              });
              await loadSheets(isRefresh: true);
              appRouter.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: boldText(14)),
          ),
        ],
      ),
    );
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> showDeleteDialog(Sheet sheet) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Sheet',
      message: 'Delete "${sheet.name}"?\nAll records inside will be permanently removed.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      await FirebaseHelper.deleteSheet(sheet.id);
      await loadSheets(isRefresh: true);
    }
  }
}
