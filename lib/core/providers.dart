import 'package:budgetly/core/import_to_export.dart';

// Global providers
final onboardingProvider = ChangeNotifierProvider<OnboardingProvider>(
  (ref) => OnboardingProvider(ref),
);
final homeProvider = ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider(ref));
final dashboardProvider = ChangeNotifierProvider<DashboardProvider>(
  (ref) => DashboardProvider(ref),
);
final categoryProvider = ChangeNotifierProvider<CategoryProvider>((ref) => CategoryProvider(ref));
final monthProvider = ChangeNotifierProvider<MonthProvider>((ref) => MonthProvider(ref));
final sheetsProvider = ChangeNotifierProvider<SheetsProvider>((ref) => SheetsProvider(ref));
final settingProvider = ChangeNotifierProvider<SettingProvider>((ref) => SettingProvider(ref));

// Screen-specific providers (autoDispose)
final notificationProvider = ChangeNotifierProvider.autoDispose<NotificationProvider>(
  (ref) => NotificationProvider(ref),
);
final profileProvider = ChangeNotifierProvider.autoDispose<ProfileProvider>(
  (ref) => ProfileProvider(ref),
);
final exportPdfProvider = ChangeNotifierProvider.autoDispose<ExportPdfProvider>(
  (ref) => ExportPdfProvider(ref),
);

// Parameterized / Screen-specific providers (family + autoDispose)
final monthDetailProvider = ChangeNotifierProvider.autoDispose.family<MonthDetailProvider, Map>((
  ref,
  args,
) {
  return MonthDetailProvider(ref, args);
});

final expenseFormProvider = ChangeNotifierProvider.autoDispose.family<ExpenseFormProvider, Map>((
  ref,
  args,
) {
  return ExpenseFormProvider(ref, args);
});

final categoryDetailsProvider = ChangeNotifierProvider.autoDispose
    .family<CategoryDetailsProvider, Map>((ref, args) {
      return CategoryDetailsProvider(ref, args);
    });

final sheetDetailsProvider = ChangeNotifierProvider.autoDispose.family<SheetDetailsProvider, Map>((
  ref,
  args,
) {
  return SheetDetailsProvider(ref, args);
});

final sheetRecordFormProvider = ChangeNotifierProvider.autoDispose
    .family<SheetRecordFormProvider, Map>((ref, args) {
      return SheetRecordFormProvider(ref, args);
    });
