import 'package:budgetly/core/import_to_export.dart';

class MonthSummary {
  final int month;
  final String monthName;
  final double budget;
  final double expense;
  final double difference;
  final double progressValue; // 0.0 – 1.0, clamped
  final bool isCurrent;
  final bool isPast;
  final bool hasData;
  final Color statusColor;
  final String statusLabel;
  final dynamic statusIcon; // HugeIcons icon key

  const MonthSummary({
    required this.month,
    required this.monthName,
    required this.budget,
    required this.expense,
    required this.difference,
    required this.progressValue,
    required this.isCurrent,
    required this.isPast,
    required this.hasData,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
  });
}
