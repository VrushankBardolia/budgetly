import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class ExportPdfScreen extends ConsumerWidget {
  const ExportPdfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthsAsync = ref.watch(pdfMonthsProvider);
    final controller = ref.read(pdfExportControllerProvider);
    final formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Export PDF", style: serifText(20)),
        centerTitle: true,
        elevation: 0,
      ),
      body: monthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        error: (err, stack) => Center(child: Text('Error loading months: $err')),
        data: (months) => months.isEmpty
            ? buildEmptyState()
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final monthInfo = months[index];
                  final totalSpent = monthInfo.expenses.fold(0.0, (total, e) => total + e.price);

                  return GestureDetector(
                    onTap: () => controller.exportToPdf(monthInfo),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(monthInfo.label, style: boldText(16)),
                        subtitle: Text(
                          '${monthInfo.expenses.length} transaction${monthInfo.expenses.length > 1 ? 's' : ''}',
                          style: regularText(12, color: AppColors.grey),
                        ),
                        dense: true,
                        trailing: Text(
                          formatter.format(totalSpent),
                          style: boldText(14, color: AppColors.brand),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 16),
          Text('No records found to export', style: regularText(14, color: AppColors.grey)),
        ],
      ),
    );
  }
}
