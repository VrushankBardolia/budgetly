import 'package:budgetly/core/import_to_export.dart';

class SheetsController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Sheet> sheets = <Sheet>[].obs;
  final RxBool isLoading = true.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadSheets();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> loadSheets({bool isRefresh = false}) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    isRefresh ? null : isLoading.value = true;
    try {
      final snapshot = await FirebaseHelper.getSheets(userId);
      sheets.assignAll(snapshot.docs.map((doc) => Sheet.fromFirestore(doc)).toList());
    } finally {
      isRefresh ? null : isLoading.value = false;
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void goToSheet(Sheet sheet) {
    Get.toNamed(Routes.SHEET_DETAIL, arguments: {'sheetId': sheet.id, 'sheetName': sheet.name});
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  Future<void> showCreateSheetDialog() async {
    final nameCtrl = TextEditingController();
    int selectedYear = DateTime.now().year;

    await Get.dialog(
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
              onPressed: Get.back,
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                await _createSheet(name: name, year: selectedYear);
                Get.back();
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

  Future<void> _createSheet({required String name, required int year}) async {
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

    await loadSheets();
  }

  // ─── Rename ───────────────────────────────────────────────────────────────

  Future<void> showRenameDialog(Sheet sheet) async {
    final nameCtrl = TextEditingController(text: sheet.name);

    await Get.dialog(
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
            onPressed: Get.back,
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
              await loadSheets();
              Get.back();
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Sheet', style: regularText(14)),
        content: Text(
          'Delete "${sheet.name}"?\nAll records inside will be permanently removed.',
          style: regularText(14, color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: regularText(14, color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: boldText(14, color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseHelper.deleteSheet(sheet.id);
      await loadSheets();
    }
  }
}
