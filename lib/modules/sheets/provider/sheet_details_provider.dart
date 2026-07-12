import 'package:budgetly/core/import_to_export.dart';

// ─── Asynchronous Data Providers ─────────────────────────────────────────────

/// Fetches and caches records for a specific sheet.
final sheetRecordsProvider = FutureProvider.family.autoDispose<List<SheetRecord>, String>((
  ref,
  sheetId,
) async {
  final repo = ref.watch(sheetRepositoryProvider);
  return repo.getRecords(sheetId);
});

// ─── Local UI State Providers ────────────────────────────────────────────────

/// Holds the filter type ('all' | 'income' | 'expense') for a specific sheet.
final sheetFilterTypeProvider = StateProvider.family.autoDispose<String, String>((ref, sheetId) {
  return 'all';
});

// ─── Combined Sheet Details State Provider ───────────────────────────────────

final sheetDetailsStateProvider = Provider.family.autoDispose<AsyncValue<SheetDetailsState>, Map>((
  ref,
  args,
) {
  final sheetId = args['sheetId'] ?? '';
  final sheetName = args['sheetName'] ?? 'Sheet';

  final asyncValues = [ref.watch(sheetRecordsProvider(sheetId))];

  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  final records = (asyncValues[0]).value ?? [];
  final filterType = ref.watch(sheetFilterTypeProvider(sheetId));

  return AsyncValue.data(
    SheetDetailsState(
      sheetId: sheetId,
      sheetName: sheetName,
      records: records,
      filterType: filterType,
    ),
  );
});

// ─── Sheet Details Action Controller ─────────────────────────────────────────

final sheetDetailsControllerProvider = Provider.family.autoDispose<SheetDetailsController, Map>((
  ref,
  args,
) {
  return SheetDetailsController(ref, args);
});

class SheetDetailsController {
  final Ref ref;
  final Map args;
  final String sheetId;

  SheetDetailsController(this.ref, this.args) : sheetId = args['sheetId'] ?? '';

  void setFilter(String type) {
    ref.read(sheetFilterTypeProvider(sheetId).notifier).state = type;
  }

  Future<void> goToAddRecord() async {
    final result = await appRouter.pushNamed(Routes.SHEET_RECORD_FORM, extra: {'sheetId': sheetId});
    if (result == true) {
      ref.invalidate(sheetRecordsProvider(sheetId));
      ref.invalidate(sheetsListProvider);
      ref.invalidate(totalSheetsBalanceProvider);
    }
  }

  Future<void> goToEditRecord(SheetRecord record) async {
    final result = await appRouter.pushNamed(
      Routes.SHEET_RECORD_FORM,
      extra: {'sheetId': sheetId, 'record': record},
    );
    if (result == true) {
      ref.invalidate(sheetRecordsProvider(sheetId));
      ref.invalidate(sheetsListProvider);
      ref.invalidate(totalSheetsBalanceProvider);
    }
  }

  Future<void> showDeleteDialog(String recordId) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Record',
      message: 'Are you sure you want to delete this record?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      final sheetRepo = ref.read(sheetRepositoryProvider);
      await sheetRepo.deleteRecord(sheetId, recordId);
      ref.invalidate(sheetRecordsProvider(sheetId));
      ref.invalidate(sheetsListProvider);
      ref.invalidate(totalSheetsBalanceProvider);
    }
  }
}
