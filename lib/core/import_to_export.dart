// ─── Flutter ────────────────────────────────────────────────────
export 'dart:convert';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// ─── Packages ────────────────────────────────────────────────────
export 'package:get/get.dart';
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
export 'package:fl_chart/fl_chart.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:local_auth/local_auth.dart';
export 'package:flutter_svg/svg.dart';

// ─── Core & Theme ──────────────────────────────────────────────────────────
export 'package:budgetly/core/theme/app_colors.dart';
export 'package:budgetly/core/theme/app_theme.dart';
export 'package:budgetly/core/theme/text_theme.dart';

// ─── Components ────────────────────────────────────────────────────────────
export 'package:budgetly/components/button.dart';
export 'package:budgetly/components/category_tile.dart';
export 'package:budgetly/components/expense_tile.dart';
export 'package:budgetly/components/google_signin_button.dart';
export 'package:budgetly/components/main_notification_tile.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────
export 'package:budgetly/core/helper/firebase_helper.dart';
export 'package:budgetly/core/helper/firebase_options.dart';
export 'package:budgetly/core/helper/notification_service.dart';
export 'package:budgetly/core/helper/preference_helper.dart';

// ─── Models ────────────────────────────────────────────────────────────────
export 'package:budgetly/core/model/category.dart';
export 'package:budgetly/core/model/expense.dart';
export 'package:budgetly/core/model/month_budget.dart';
export 'package:budgetly/core/model/user_model.dart';
export 'package:budgetly/core/model/month_summery.dart';

// ─── Routes ────────────────────────────────────────────────────────────────
export 'package:budgetly/core/routes/app_pages.dart';

// ─── Modules (Home) ────────────────────────────────────────────────────────
export 'package:budgetly/modules/home/controller/home_controller.dart';
export 'package:budgetly/modules/home/view/home_screen.dart';

// ─── Modules (Auth) ────────────────────────────────────────────────────────
export 'package:budgetly/modules/auth/view/app_lock_screen.dart';
export 'package:budgetly/modules/auth/controller/onboarding_controller.dart';
export 'package:budgetly/modules/auth/view/onboarding_screen.dart';
export 'package:budgetly/modules/auth/view/initial_loader_screen.dart';

// ─── Modules (Categories) ──────────────────────────────────────────────────
export 'package:budgetly/modules/catregories/controller/category_controller.dart';
export 'package:budgetly/modules/catregories/view/categories_tab.dart';

// ─── Modules (Dashboard) ───────────────────────────────────────────────────
export 'package:budgetly/modules/dashboard/view/dashboard_tab.dart';
export 'package:budgetly/modules/dashboard/controller/dashboard_controller.dart';

// ─── Modules (Months) ──────────────────────────────────────────────────────
export 'package:budgetly/modules/months/view/expense_form_screen.dart';
export 'package:budgetly/modules/months/view/month_details_screen.dart';
export 'package:budgetly/modules/months/view/months_tab.dart';
export 'package:budgetly/modules/months/controller/month_controller.dart';
export 'package:budgetly/modules/months/controller/expense_form_controller.dart';
export 'package:budgetly/modules/months/controller/month_details_controller.dart';

// ─── Modules (Settings) ────────────────────────────────────────────────────
export 'package:budgetly/modules/settings/controller/notification_controller.dart';
export 'package:budgetly/modules/settings/controller/setting_controller.dart';
export 'package:budgetly/modules/settings/view/notification_screen.dart';
export 'package:budgetly/modules/settings/view/settings_shimmer_loader.dart';
export 'package:budgetly/modules/settings/view/settings_tab.dart';

// ─── Modules (Root) ────────────────────────────────────────────────────────
export 'package:budgetly/main.dart';
