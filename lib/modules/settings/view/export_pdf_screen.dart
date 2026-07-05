import 'package:budgetly/core/import_to_export.dart';

class ExportPdfScreen extends ConsumerWidget {
  const ExportPdfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(exportPdfProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Export PDF"), centerTitle: true, elevation: 0),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : prov.months.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
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
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: prov.months.length,
              itemBuilder: (context, index) {
                final monthInfo = prov.months[index];
                final totalSpent = monthInfo.expenses.fold(0.0, (total, e) => total + e.price);

                return GestureDetector(
                  onTap: () => prov.exportToPdf(monthInfo),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.mainCardGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(monthInfo.label, style: boldText(16)),
                      subtitle: Text(
                        '${monthInfo.expenses.length} transaction${monthInfo.expenses.length > 1 ? 's' : ''}',
                        style: regularText(12, color: AppColors.grey),
                      ),
                      trailing: Text(
                        prov.formatter.format(totalSpent),
                        style: boldText(13, color: AppColors.brand),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
