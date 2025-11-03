import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/router.dart'; // make sure this file exists

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🪟 Configure desktop window
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 800);
    win
      ..minSize = const Size(800, 600)
      ..size = initialSize
      ..alignment = Alignment.center
      ..title = "Vegetable Trading & Farmer Account Management System"
      ..show();
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

/// ==============================
/// 🧭 App Shell – Main Layout
/// ==============================
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/billing')) return 1;
    if (location.startsWith('/stock')) return 2;
    if (location.startsWith('/farmers')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _calculateSelectedIndex(context);

    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: MoveWindow(
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Vegetable Trading & Farmer Account Management System",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        actions: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [WindowButtons()],
        ),
      ),

      // 🧱 Side Navigation Pane
      pane: NavigationPane(
        displayMode: PaneDisplayMode.auto,
        selected: index,
        onChanged: (i) {
          switch (i) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/billing');
              break;
            case 2:
              context.go('/stock');
              break;
            case 3:
              context.go('/farmers');
              break;
            default:
              context.go('/dashboard');
          }
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Dashboard'),
            body: const Center(child: Text('Dashboard Page')), // 👈 required
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bill),
            title: const Text('New Bill'),
            body: const Center(child: Text('Billing Page')), // 👈 required
          ),
          PaneItem(
            icon: const Icon(FluentIcons.product_catalog),
            title: const Text('Stock'),
            body: const Center(child: Text('Stock Page')), // 👈 required
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact_list),
            title: const Text('Farmers'),
            body: const Center(child: Text('Farmers Page')), // 👈 required
          ),
        ],
      ),

      // ✅ The main content is no longer NavigationBody, the NavigationPane items manage it
    );
  }
}

/// ==============================
/// 🪟 Custom Window Buttons
/// ==============================
class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final buttonColors = WindowButtonColors(
      iconNormal: theme.iconTheme.color ?? Colors.black,
      mouseOver: theme.accentColor,
      mouseDown: theme.accentColor.darker,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: theme.iconTheme.color ?? Colors.black,
      mouseOver: Colors.red,
      mouseDown: Colors.red.darker,
      iconMouseOver: Colors.white,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
