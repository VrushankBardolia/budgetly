// ─── Flutter ────────────────────────────────────────────────────
export 'dart:convert';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// ─── Packages ────────────────────────────────────────────────────
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:toastification/toastification.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:hugeicons/hugeicons.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:shimmer/shimmer.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:google_sign_in/google_sign_in.dart';
export 'package:pull_down_button/pull_down_button.dart';
export 'package:animated_digit/animated_digit.dart';
export 'package:syncfusion_flutter_charts/charts.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:local_auth/local_auth.dart';
export 'package:flutter_svg/svg.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:path_provider/path_provider.dart';
export 'package:pdf/pdf.dart';
export 'package:printing/printing.dart';
export 'package:open_filex/open_filex.dart';
export 'package:go_router/go_router.dart';

// ─── Core & Theme ──────────────────────────────────────────────────────────
export 'package:budgetly/core/theme/app_colors.dart';
export 'package:budgetly/core/theme/app_theme.dart';
export 'package:budgetly/core/theme/text_theme.dart';
export 'package:budgetly/core/providers.dart';

// ─── Repositories ─────────────────────────────────────────────────────────────
export 'package:budgetly/core/repositories/expense_repository.dart';
export 'package:budgetly/core/repositories/budget_repository.dart';
export 'package:budgetly/core/repositories/category_repository.dart';
export 'package:budgetly/core/repositories/sheet_repository.dart';
export 'package:budgetly/core/repositories/user_repository.dart';

// ─── Components ────────────────────────────────────────────────────────────
export 'package:budgetly/components/amount_field.dart';
export 'package:budgetly/components/button.dart';
export 'package:budgetly/components/category_tile.dart';
export 'package:budgetly/components/date_picker_field.dart';
export 'package:budgetly/components/detail_field.dart';
export 'package:budgetly/components/expense_tile.dart';
export 'package:budgetly/components/google_signin_button.dart';
export 'package:budgetly/components/main_notification_tile.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────
export 'package:budgetly/core/helper/firebase_helper.dart';
export 'package:budgetly/core/helper/firebase_logger.dart';
export 'package:budgetly/core/helper/commons.dart';
export 'package:budgetly/core/helper/firebase_options.dart';
export 'package:budgetly/core/helper/notification_service.dart';
export 'package:budgetly/core/helper/preference_helper.dart';
export 'package:budgetly/core/helper/export_pdf_helper.dart';
export 'package:budgetly/core/helper/widget_helper.dart';

// ─── Models ────────────────────────────────────────────────────────────────
export 'package:budgetly/core/model/category.dart';
export 'package:budgetly/core/model/expense.dart';
export 'package:budgetly/core/model/month_budget.dart';
export 'package:budgetly/core/model/user_model.dart';
export 'package:budgetly/core/model/month_summery.dart';
export 'package:budgetly/core/model/sheet.dart';
export 'package:budgetly/core/model/sheet_record.dart';

// ─── Routes ────────────────────────────────────────────────────────────────
export 'package:budgetly/core/routes/app_router.dart';

// ─── Modules (Home) ────────────────────────────────────────────────────────
export 'package:budgetly/modules/home/provider/home_provider.dart';
export 'package:budgetly/modules/home/view/home_screen.dart';

// ─── Modules (Auth) ────────────────────────────────────────────────────────
export 'package:budgetly/modules/auth/view/app_lock_screen.dart';
export 'package:budgetly/modules/auth/provider/onboarding_provider.dart';
export 'package:budgetly/modules/auth/view/onboarding_screen.dart';
export 'package:budgetly/modules/auth/view/initial_loader_screen.dart';

// ─── Modules (Categories) ──────────────────────────────────────────────────
export 'package:budgetly/modules/catregories/state/categories_state.dart';
export 'package:budgetly/modules/catregories/state/category_details_state.dart';
export 'package:budgetly/modules/catregories/provider/category_provider.dart';
export 'package:budgetly/modules/catregories/provider/category_details_provider.dart';
export 'package:budgetly/modules/catregories/view/categories_tab.dart';
export 'package:budgetly/modules/catregories/view/category_details_screen.dart';

// ─── Modules (Dashboard) ───────────────────────────────────────────────────
export 'package:budgetly/modules/dashboard/view/dashboard_tab.dart';
export 'package:budgetly/modules/dashboard/provider/dashboard_provider.dart';
export 'package:budgetly/modules/dashboard/state/dashboard_state.dart';

// ─── Modules (Months) ──────────────────────────────────────────────────────
export 'package:budgetly/modules/months/state/month_state.dart';
export 'package:budgetly/modules/months/state/month_detail_state.dart';
export 'package:budgetly/modules/months/view/expense_form_screen.dart';
export 'package:budgetly/modules/months/view/month_details_screen.dart';
export 'package:budgetly/modules/months/view/months_tab.dart';
export 'package:budgetly/modules/months/provider/month_provider.dart';
export 'package:budgetly/modules/months/provider/expense_form_provider.dart';
export 'package:budgetly/modules/months/provider/month_details_provider.dart';

// ─── Modules (Sheets) ──────────────────────────────────────────────────────
export 'package:budgetly/modules/sheets/state/sheets_state.dart';
export 'package:budgetly/modules/sheets/state/sheet_details_state.dart';
export 'package:budgetly/modules/sheets/view/sheet_details_screen.dart';
export 'package:budgetly/modules/sheets/view/sheet_record_form_screen.dart';
export 'package:budgetly/modules/sheets/view/sheets_tab.dart';
export 'package:budgetly/modules/sheets/provider/sheets_provider.dart';
export 'package:budgetly/modules/sheets/provider/sheet_details_provider.dart';
export 'package:budgetly/modules/sheets/provider/sheet_record_form_provider.dart';

// ─── Modules (Settings) ────────────────────────────────────────────────────
export 'package:budgetly/modules/settings/state/setting_state.dart';
export 'package:budgetly/modules/settings/provider/export_pdf_provider.dart';
export 'package:budgetly/modules/settings/provider/notification_provider.dart';
export 'package:budgetly/modules/settings/provider/setting_provider.dart';
export 'package:budgetly/modules/settings/provider/profile_provider.dart';
export 'package:budgetly/modules/settings/view/export_pdf_screen.dart';
export 'package:budgetly/modules/settings/view/notification_screen.dart';
export 'package:budgetly/modules/settings/view/settings_shimmer_loader.dart';
export 'package:budgetly/modules/settings/view/profile_screen.dart';
export 'package:budgetly/modules/settings/view/about_sheet.dart';
export 'package:budgetly/modules/settings/view/settings_tab.dart';

// ─── Modules (Root) ────────────────────────────────────────────────────────
export 'package:budgetly/main.dart';
