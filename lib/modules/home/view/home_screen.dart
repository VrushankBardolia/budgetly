import 'package:budgetly/core/import_to_export.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: controller.screens[controller.currentIndex.value],
        bottomNavigationBar: Theme(
          data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
          child: BottomNavigationBar(
            onTap: (value) {
              HapticFeedback.heavyImpact();
              controller.changeIndex(value);
            },
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
            currentIndex: controller.currentIndex.value,
            unselectedItemColor: Colors.grey.shade700,
            backgroundColor: Theme.of(context).colorScheme.background,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            items: [
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedHome11),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                label: 'Months',
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListDash),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
