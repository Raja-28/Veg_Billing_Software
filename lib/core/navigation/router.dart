import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:vegbill/features/billing/billing_screen.dart';
import 'package:vegbill/features/dashboard/home_screen.dart';
import 'package:vegbill/features/farmers/farmer_detail_screen.dart';
import 'package:vegbill/features/farmers/farmers_screen.dart';
import 'package:vegbill/features/stock/stock_screen.dart';
import 'package:vegbill/features/reports/bills_screen.dart';
import 'package:vegbill/core/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',

  // 🔹 Show a nice fallback if a route doesn't exist
  errorBuilder: (context, state) => const ScaffoldPage(
    header: PageHeader(title: Text('Error')),
    content: Center(child: Text('404 — Page Not Found')),
  ),

  routes: [
    ShellRoute(
      // ✅ This ensures the navigation pane is always visible
      builder: (context, state, child) => AppShell(child: child),

      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/billing',
          name: 'billing',
          builder: (context, state) => const BillingScreen(),
        ),
        GoRoute(
          path: '/stock',
          name: 'stock',
          builder: (context, state) => const StockScreen(),
        ),
        GoRoute(
          path: '/farmers',
          name: 'farmers',
          builder: (context, state) => const FarmersScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'farmerDetail',
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final id = int.tryParse(idStr ?? '');
                if (id == null) {
                  return const Center(
                    child: Text('Invalid farmer ID'),
                  );
                }
                return FarmerDetailScreen(farmerId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const BillsScreen(),
        ),
      ],
    ),
  ],
);
