import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vegbill/features/billing/billing_screen.dart';
import 'package:vegbill/features/dashboard/home_screen.dart';
import 'package:vegbill/features/farmers/farmer_detail_screen.dart';
import 'package:vegbill/features/farmers/farmers_screen.dart';
import 'package:vegbill/features/stock/stock_screen.dart';
import 'package:vegbill/features/reports/bills_screen.dart';
import 'package:vegbill/features/auth/pin_setup_screen.dart';
import 'package:vegbill/features/auth/pin_lock_screen.dart';
import 'package:vegbill/features/auth/pin_settings_screen.dart';
import 'package:vegbill/features/settings/settings_screen.dart';
import 'package:vegbill/features/analytics/analytics_screen.dart';
import 'package:vegbill/core/app_shell.dart';
import 'package:vegbill/core/services/pin_auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Create router with PIN authentication
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    
    // Redirect logic for PIN authentication
    redirect: (context, state) async {
      final pinService = ref.read(pinAuthServiceProvider);
      final authState = ref.read(authStateProvider);
      final isPinSet = await pinService.isPinSet();
      
      final isOnAuthPage = state.matchedLocation == '/pin-setup' || 
                           state.matchedLocation == '/pin-lock';
      
      // If PIN is not set, redirect to setup
      if (!isPinSet && state.matchedLocation != '/pin-setup') {
        return '/pin-setup';
      }
      
      // If PIN is set but not authenticated, redirect to lock screen
      if (isPinSet && 
          authState == AuthState.unauthenticated && 
          !isOnAuthPage) {
        return '/pin-lock';
      }
      
      // If authenticated and on auth page, redirect to dashboard
      if (authState == AuthState.authenticated && isOnAuthPage) {
        return '/dashboard';
      }
      
      return null; // No redirect needed
    },
    
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.notifier).stream),

  // 🔹 Show a nice fallback if a route doesn't exist
  errorBuilder: (context, state) => const ScaffoldPage(
    header: PageHeader(title: Text('Error')),
    content: Center(child: Text('404 — Page Not Found')),
  ),

    routes: [
      // PIN Setup Route (outside shell)
      GoRoute(
        path: '/pin-setup',
        name: 'pinSetup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      
      // PIN Lock Route (outside shell)
      GoRoute(
        path: '/pin-lock',
        name: 'pinLock',
        builder: (context, state) => const PinLockScreen(),
      ),
      
      // Main app routes (inside shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
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
        GoRoute(
          path: '/pin-settings',
          name: 'pinSettings',
          builder: (context, state) => const PinSettingsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          name: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
      ],
      ),
    ],
  );
}

/// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (event) => notifyListeners(),
    );
  }
  
  late final StreamSubscription<AuthState> _subscription;
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
