import 'package:budgetly/core/import_to_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  await GoogleFonts.pendingFonts([GoogleFonts.plusJakartaSans(), GoogleFonts.staatliches()]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Budgetly',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: themeData,
        routerConfig: appRouter,
        scaffoldMessengerKey: scaffoldMessengerKey,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
            child: child!,
          );
        },
      ),
    );
  }
}

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(onboardingProvider);

    if (prov.isCheckingAuth) {
      return const InitialLoaderScreen();
    }

    if (FirebaseHelper.currentUser != null) {
      if (PreferenceHelper.isEnabledBiometric) {
        return const AppLockScreen();
      }
      return const HomeScreen();
    }
    return const OnboardingScreen();
  }
}
