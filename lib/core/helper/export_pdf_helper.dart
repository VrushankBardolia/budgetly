import 'dart:io';

import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  // ─── Brand colours (mapped from AppColors) ─────────────────────────────────
  static const _brand = PdfColor.fromInt(0xFF1565C0); // brand blue (darker for readability)
  static const _brandDark = PdfColor.fromInt(0xFF0D47A1); // dark navy
  static const _black = PdfColor.fromInt(0xFF212121); // primary text color in light mode (charcoal)
  static const _surface = PdfColor.fromInt(0xFFF8F9FA); // card/row bg 1 (light grey)
  static const _surfaceLight = PdfColor.fromInt(0xFFFFFFFF); // card/row bg 2 (white)
  static const _border = PdfColor.fromInt(0xFFE0E0E0); // light border
  static const _grey = PdfColor.fromInt(0xFF616161); // secondary text
  static const _hint = PdfColor.fromInt(0xFF757575); // hint
  static const _error = PdfColor.fromInt(0xFFD32F2F); // readable red
  static const _warning = PdfColor.fromInt(0xFFEF6C00); // readable orange/amber
  static const _success = PdfColor.fromInt(0xFF2E7D32); // readable green
  static const _white = PdfColors.white;

  // Light tints for card backgrounds
  static const _brandTint = PdfColor.fromInt(0xFFE3F2FD);
  // static const _warningTint = PdfColor.fromInt(0xFFFFF3E0);
  static const _errorTint = PdfColor.fromInt(0xFFFFEBEE);
  static const _successTint = PdfColor.fromInt(0xFFE8F5E9);

  static final _currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  static final _dateFmt = DateFormat('dd MMM');
  static final _fullDateFmt = DateFormat('dd MMM yyyy');

  // ───────────────────────────────────────────────────────────────────────────
  /// Entry point — builds and saves the PDF. Returns the saved file path.
  // ───────────────────────────────────────────────────────────────────────────
  static Future<String> exportMonthlyReport({
    required List<Expense> expenses,
    required double budget,
    required int month,
    required int year,
    required String userName,
    Map<String, String>? categoryNames,
    bool includeCategoryBreakdown = true,
    bool includeTransactions = true,
  }) async {
    // Load Unicode-supported fonts from Google Fonts
    final baseFont = await PdfGoogleFonts.plusJakartaSansRegular();
    final boldFont = await PdfGoogleFonts.plusJakartaSansBold();
    final fallbackFont = await PdfGoogleFonts.notoSansDevanagariRegular();

    final doc = pw.Document(
      title: 'Budgetly — ${DateFormat('MMMM yyyy').format(DateTime(year, month))}',
      author: 'Budgetly',
    );

    // ── Derived data ──────────────────────────────────────────────────────────
    final totalExpense = expenses.fold(0.0, (total, e) => total + e.price);

    final Map<String, double> categoryTotals = {};
    for (final e in expenses) {
      final name = categoryNames?[e.categoryId] ?? e.categoryId;
      categoryTotals[name] = (categoryTotals[name] ?? 0) + e.price;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedTransactions = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(year, month));

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(baseFont, boldFont, fallbackFont),
        header: (_) => _header(monthLabel, userName),
        footer: (ctx) => _footer(ctx),
        build: (_) => [
          _summarySection(totalExpense, budget, expenses.length),
          if (includeCategoryBreakdown) ...[
            pw.SizedBox(height: 20),
            _categorySection(sortedCategories, totalExpense),
          ],
          if (includeTransactions) ...[
            pw.SizedBox(height: 20),
            _transactionSection(sortedTransactions, categoryNames),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await _resolveOutputDir();
    final fileName = 'Budgetly_${DateFormat('MMM_yyyy').format(DateTime(year, month))}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // ─── Page Theme ────────────────────────────────────────────────────────────
  static pw.PageTheme _pageTheme(pw.Font baseFont, pw.Font boldFont, pw.Font fallbackFont) =>
      pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont, fontFallback: [fallbackFont]),
        buildBackground: (ctx) =>
            pw.FullPage(ignoreMargins: true, child: pw.Container(color: _white)),
      );

  // ─── Header ────────────────────────────────────────────────────────────────
  static pw.Widget _header(String monthLabel, String userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo + app name
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 28,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    color: _brand,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.SvgImage(
                      svg:
                          '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#FFFFFF"><path d="M240-160q-66 0-113-47T80-320v-320q0-66 47-113t113-47h480q66 0 113 47t47 113v320q0 66-47 113t-113 47H240Zm0-480h480q22 0 42 5t38 16v-21q0-33-23.5-56.5T720-720H240q-33 0-56.5 23.5T160-640v21q18-11 38-16t42-5Zm-74 130 445 108q9 2 18 0t17-8l139-116q-11-15-28-24.5t-37-9.5H240q-26 0-45.5 13.5T166-510Z"/></svg>',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Budgetly',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _brand,
                      ),
                    ),
                    pw.Text(
                      'Monthly Expense Report',
                      style: pw.TextStyle(fontSize: 8, color: _grey),
                    ),
                  ],
                ),
              ],
            ),
            // Month + user
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  monthLabel,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _black),
                ),
                pw.SizedBox(height: 2),
                pw.Text(userName, style: pw.TextStyle(fontSize: 9, color: _grey)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _border, thickness: 0.5),
        pw.SizedBox(height: 6),
      ],
    );
  }

  // ─── Footer ────────────────────────────────────────────────────────────────
  static pw.Widget _footer(pw.Context ctx) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 4),
        pw.Divider(color: _border, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by Budgetly • ${_fullDateFmt.format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 7, color: _hint),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 7, color: _hint),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Summary Section ───────────────────────────────────────────────────────
  static pw.Widget _summarySection(double totalExpense, double budget, int txCount) {
    final difference = budget - totalExpense;
    final isOverBudget = difference < 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Summary'),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _statCard(
                label: 'Total Spent this Month',
                value: _currencyFmt.format(totalExpense),
                color: _brandDark,
                bgColor: _brandTint,
                borderColor: _brand,
                subtext: '$txCount transactions',
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _statCard(
                label: 'Monthly Budget',
                value: _currencyFmt.format(budget),
                color: _brand,
                bgColor: _brandTint,
                borderColor: _brand,
                subtext: 'Allocated budget',
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _statCard(
                label: isOverBudget ? 'Over Budget By' : 'Remaining Budget',
                value: _currencyFmt.format(difference.abs()),
                color: isOverBudget ? _error : _success,
                bgColor: isOverBudget ? _errorTint : _successTint,
                borderColor: isOverBudget ? _error : _success,
                subtext: isOverBudget ? 'Limit exceeded' : 'Available balance',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _statCard({
    required String label,
    required String value,
    required PdfColor color,
    required PdfColor bgColor,
    required PdfColor borderColor,
    required String subtext,
  }) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: pw.BoxDecoration(
      color: bgColor,
      borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border.all(
        color: PdfColor(borderColor.red, borderColor.green, borderColor.blue, 0.3),
        width: 0.5,
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: _grey)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
        ),
        pw.SizedBox(height: 4),
        pw.Text(subtext, style: pw.TextStyle(fontSize: 8, color: _grey)),
      ],
    ),
  );

  // ─── Category Breakdown ────────────────────────────────────────────────────
  static pw.Widget _categorySection(
    List<MapEntry<String, double>> categories,
    double totalExpense,
  ) {
    if (categories.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Category Breakdown'),
        pw.SizedBox(height: 10),
        // Table header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: _surface,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(flex: 2, child: _headerText('Category Name')),
              pw.Expanded(flex: 3, child: _headerText('Progress')),
              pw.Expanded(flex: 2, child: _headerText('Amount & %', right: true)),
            ],
          ),
        ),
        // Table rows
        ...categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final pct = totalExpense > 0 ? cat.value / totalExpense : 0.0;
          final isLast = i == categories.length - 1;

          // Top 3 use distinct accent colours
          final barColor = i == 0
              ? _error
              : i == 1
              ? _warning
              : _brand;

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: pw.BoxDecoration(
              color: i.isEven ? _surfaceLight : _surface,
              border: pw.Border(
                bottom: isLast ? pw.BorderSide.none : pw.BorderSide(color: _border, width: 0.3),
              ),
              borderRadius: isLast
                  ? const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(8),
                      bottomRight: pw.Radius.circular(8),
                    )
                  : null,
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    cat.key,
                    style: pw.TextStyle(fontSize: 9, color: _black),
                    maxLines: 1,
                  ),
                ),
                // Progress bar
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    height: 7,
                    margin: const pw.EdgeInsets.only(right: 12),
                    decoration: pw.BoxDecoration(
                      color: _border,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Row(
                      children: [
                        if ((pct.clamp(0.0, 1.0) * 1000).toInt() > 0)
                          pw.Expanded(
                            flex: (pct.clamp(0.0, 1.0) * 1000).toInt(),
                            child: pw.Container(
                              height: 7,
                              decoration: pw.BoxDecoration(
                                color: barColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        if (((1.0 - pct.clamp(0.0, 1.0)) * 1000).toInt() > 0)
                          pw.Expanded(
                            flex: ((1.0 - pct.clamp(0.0, 1.0)) * 1000).toInt(),
                            child: pw.SizedBox(),
                          ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '${_currencyFmt.format(cat.value)}  (${(pct * 100).toStringAsFixed(1)}%)',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _black),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Transaction List ──────────────────────────────────────────────────────
  static pw.Widget _transactionSection(List<Expense> expenses, Map<String, String>? categoryNames) {
    if (expenses.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Transactions'),
        pw.SizedBox(height: 10),
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            color: _surface,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(width: 48, child: _headerText('Date')),
              pw.Expanded(flex: 3, child: _headerText('Detail')),
              pw.Expanded(flex: 2, child: _headerText('Category')),
              pw.SizedBox(width: 80, child: _headerText('Amount', right: true)),
            ],
          ),
        ),
        // Rows
        ...expenses.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final categoryLabel = categoryNames?[e.categoryId] ?? e.categoryId;
          final isLast = i == expenses.length - 1;

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: pw.BoxDecoration(
              color: i.isEven ? _surfaceLight : _surface,
              border: pw.Border(
                bottom: isLast ? pw.BorderSide.none : pw.BorderSide(color: _border, width: 0.3),
              ),
              borderRadius: isLast
                  ? const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(8),
                      bottomRight: pw.Radius.circular(8),
                    )
                  : null,
            ),
            child: pw.Row(
              children: [
                // Date
                pw.SizedBox(
                  width: 48,
                  child: pw.Text(
                    _dateFmt.format(e.date),
                    style: pw.TextStyle(fontSize: 8, color: _black),
                  ),
                ),
                // Detail
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    e.detail.isNotEmpty ? e.detail : '—',
                    style: pw.TextStyle(fontSize: 9, color: _black),
                    maxLines: 1,
                  ),
                ),
                // Category pill
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(categoryLabel, style: pw.TextStyle(fontSize: 9, color: _brand)),
                ),
                // Amount
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    _currencyFmt.format(e.price),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _error),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Shared helpers ────────────────────────────────────────────────────────
  static pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 3,
          height: 14,
          decoration: pw.BoxDecoration(color: _brand, borderRadius: pw.BorderRadius.circular(2)),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _black),
        ),
      ],
    ),
  );

  static pw.Widget _headerText(String text, {bool right = false}) => pw.Text(
    text,
    textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _grey),
  );

  static Future<Directory> _resolveOutputDir() async {
    if (Platform.isAndroid) {
      try {
        final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (dirs != null && dirs.isNotEmpty) return dirs.first;
      } catch (_) {}
    }
    return getApplicationDocumentsDirectory();
  }
}
