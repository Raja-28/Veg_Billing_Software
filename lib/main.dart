import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'core/navigation/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: MyApp()));
}

/// ==============================
/// 🟢 Root Application
/// ==============================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'VegBill',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.green,
        visualDensity: VisualDensity.standard,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.green,
        visualDensity: VisualDensity.standard,
      ),
      routerConfig: router,
    );
  }
}
