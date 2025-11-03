import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:go_router/go_router.dart';

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
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bill),
            title: const Text('New Bill'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.product_catalog),
            title: const Text('Stock'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact_list),
            title: const Text('Farmers'),
            body: const SizedBox.shrink(),
          ),
        ],
      ),

      content: widget.child,
    );
  }
}

/// ✅ Window buttons (bitsdojo_window)
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
      mouseOver: Colors.red,
      mouseDown: Colors.red.darker,
      iconNormal: theme.iconTheme.color ?? Colors.black,
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
