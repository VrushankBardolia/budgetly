import 'package:budgetly/core/import_to_export.dart';

class Routes {
  static const INITIAL = '/';
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const MONTH_DETAILS = '/month-details';
  static const NOTIFICATIONS = '/notifications';
  static const EXPENSE_FORM = '/expense-form';
  static const PROFILE = '/profile';
  static const ABOUT = '/about';
  static const CATEGORY_DETAILS = '/category-details';
  static const SHEET_DETAIL = '/sheet-detail';
  static const SHEET_RECORD_FORM = '/sheet-record-form';
  static const EXPORT_PDF = '/export-pdf';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.INITIAL,
  routes: [
    GoRoute(
      path: Routes.INITIAL,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const InitialScreen(), arguments: state.extra),
    ),
    GoRoute(
      path: Routes.HOME,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const HomeScreen(), arguments: state.extra),
    ),
    GoRoute(
      path: Routes.ONBOARDING,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const OnboardingScreen(), arguments: state.extra),
    ),
    GoRoute(
      path: Routes.MONTH_DETAILS,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MonthDetailScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.NOTIFICATIONS,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const NotificationScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.EXPENSE_FORM,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ExpenseFormScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.PROFILE,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ProfileScreen(), arguments: state.extra),
    ),
    GoRoute(
      path: Routes.CATEGORY_DETAILS,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CategoryDetailsScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.SHEET_DETAIL,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SheetDetailsScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.SHEET_RECORD_FORM,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SheetRecordFormScreen(),
        arguments: state.extra,
      ),
    ),
    GoRoute(
      path: Routes.EXPORT_PDF,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ExportPdfScreen(), arguments: state.extra),
    ),
  ],
);
