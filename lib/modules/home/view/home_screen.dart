import 'package:budgetly/core/import_to_export.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(homeProvider);

    return Scaffold(
      body: prov.screens[prov.currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: BottomNavigationBar(
          onTap: (value) {
            HapticFeedback.heavyImpact();
            prov.changeIndex(value);
          },
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: boldText(14, color: Colors.white),
          unselectedLabelStyle: regularText(14, color: Colors.grey),
          currentIndex: prov.currentIndex,
          unselectedItemColor: Colors.grey.shade700,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: [
            BottomNavigationBarItem(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedHome11),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
              label: 'Months',
            ),
            BottomNavigationBarItem(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListDash),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedFile02),
              label: 'Sheets',
            ),
            BottomNavigationBarItem(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
