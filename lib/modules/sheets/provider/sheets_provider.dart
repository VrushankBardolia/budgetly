import 'package:budgetly/core/import_to_export.dart';

// ─── Asynchronous Data Providers ─────────────────────────────────────────────

/// Fetches and caches the user's sheets list.
final sheetsListProvider = FutureProvider<List<Sheet>>((ref) async {
  final repo = ref.watch(sheetRepositoryProvider);
  return repo.getSheets();
});

// ─── Combined Sheets State Provider ──────────────────────────────────────────

final sheetsStateProvider = Provider<AsyncValue<SheetsState>>((ref) {
  final sheetsAsync = ref.watch(sheetsListProvider);

  return sheetsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (sheets) => AsyncValue.data(SheetsState(sheets: sheets)),
  );
});

// ─── Sheets Action Controller ────────────────────────────────────────────────

final sheetsControllerProvider = Provider<SheetsController>((ref) {
  return SheetsController(ref);
});

class SheetsController {
  final Ref ref;
  SheetsController(this.ref);

  Future<void> showCreateSheetDialog() async {
    final nameCtrl = TextEditingController();
    const selectedYear = 2026; // Default to app standard, or current year

    await dialog(
      AlertDialog(
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
    );
  }

  Future<void> _createSheet(String name, int year) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final sheetRepo = ref.read(sheetRepositoryProvider);
    await sheetRepo.addSheet({
      'userId': userId,
      'name': name,
      'year': year,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'records': [],
    });

    ref.invalidate(sheetsListProvider);
    ref.invalidate(totalSheetsBalanceProvider);
  }

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
              final sheetRepo = ref.read(sheetRepositoryProvider);
              await sheetRepo.updateSheet(sheet.id, {
                'name': name,
                'updatedAt': Timestamp.fromDate(DateTime.now()),
              });
              ref.invalidate(sheetsListProvider);
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

  Future<void> showDeleteDialog(Sheet sheet) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Sheet',
      message: 'Delete "${sheet.name}"?\nAll records inside will be permanently removed.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      final sheetRepo = ref.read(sheetRepositoryProvider);
      await sheetRepo.deleteSheet(sheet.id);
      ref.invalidate(sheetsListProvider);
      ref.invalidate(totalSheetsBalanceProvider);
    }
  }
}
