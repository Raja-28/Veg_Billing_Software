import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:go_router/go_router.dart';
import 'services/pin_auth_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/billing')) return 1;
    if (location.startsWith('/stock')) return 2;
    if (location.startsWith('/farmers')) return 3;
    if (location.startsWith('/reports')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _calculateSelectedIndex(context);

    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        height: 40,
        title: MoveWindow(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Icon(FluentIcons.shop, size: 18),
                SizedBox(width: 8),
                Text(
                  "VegBill - Farmer Account System",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
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
          // Use post-frame callback to avoid navigation during widget disposal
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              
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
                case 4:
                  context.go('/reports');
                  break;
                default:
                  context.go('/dashboard');
              }
            });
          }
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Dashboard'),
            body: widget.child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bill),
            title: const Text('New Bill'),
            body: widget.child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.product_catalog),
            title: const Text('Stock'),
            body: widget.child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact_list),
            title: const Text('Farmers'),
            body: widget.child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.report_document),
            title: const Text('Reports'),
            body: widget.child,
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.permissions),
            title: const Text('PIN Settings'),
            body: widget.child,
            onTap: () {
              context.go('/pin-settings');
            },
          ),
          PaneItem(
            icon: const Icon(FluentIcons.lock),
            title: const Text('Lock App'),
            body: widget.child,
            onTap: () {
              // Lock the app
              ref.read(authStateProvider.notifier).lock();
              context.go('/pin-lock');
            },
          ),
        ],
      ),
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
