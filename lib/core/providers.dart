import 'package:budgetly/core/import_to_export.dart';

// ─── Global System State Providers ───────────────────────────────────────────

final onboardingProvider = ChangeNotifierProvider<OnboardingProvider>(
  (ref) => OnboardingProvider(ref),
);

final homeProvider = ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider(ref));

// ─── Form-Specific Providers (autoDispose + family) ──────────────────────────

final expenseFormProvider = ChangeNotifierProvider.autoDispose.family<ExpenseFormProvider, Map>((
  ref,
  args,
) {
  return ExpenseFormProvider(ref, args);
});

final sheetRecordFormProvider = ChangeNotifierProvider.autoDispose
    .family<SheetRecordFormProvider, Map>((ref, args) {
      return SheetRecordFormProvider(ref, args);
    });
