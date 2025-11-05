import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'core/navigation/router.dart';
import 'core/services/pin_auth_service.dart';
import 'core/services/pin_auth_provider.dart';
import 'core/services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Initialize PIN authentication service
  final pinAuthService = await PinAuthService.initialize();

  // 🪟 Configure desktop window
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 800);
    win.minSize = const Size(800, 600);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Vegetable Trading & Farmer Account Management System";
    win.show();
  });

  runApp(
    ProviderScope(
      overrides: [
        // Override the PIN auth service provider with initialized instance
        pinAuthServiceProvider.overrideWithValue(pinAuthService),
      ],
      child: const MyApp(),
    ),
  );
}

/// ==============================
/// 🟢 Root Application
/// ==============================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create router with ref for PIN authentication
    final router = createRouter(ref);
    final themeMode = ref.watch(themeModeProvider);
    
    return FluentApp.router(
      title: 'VegBill',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      routerConfig: router,
    );
  }
}
