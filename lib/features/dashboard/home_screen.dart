import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:intl/intl.dart';

// 1. Converted to ConsumerWidget to read Riverpod providers
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch our new dashboard providers
    final farmerCountAsync = ref.watch(totalFarmerCountProvider);
    final recentActivityAsync = ref.watch(recentActivityProvider);

    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Dashboard'),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATS BAR ---
            InfoBar(
              title: const Text('At a Glance'),
              content: Row(
                children: [
                  // Total Farmers Card
                  farmerCountAsync.when(
                    data: (count) => StatCard(
                      title: 'Total Farmers',
                      value: count.toString(),
                      icon: FluentIcons.contact_list,
                      color: Colors.blue,
                    ),
                    loading: () => const StatCard(
                      title: 'Total Farmers',
                      value: '...',
                      icon: FluentIcons.contact_list,
                    ),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(width: 16),
                  // Placeholder for more stats
                  const StatCard(
                    title: 'Total Stock (KG)',
                    value: 'N/A',
                    icon: FluentIcons.product_catalog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- RECENT ACTIVITY ---
            Text(
              'Recent Activity',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                padding: EdgeInsets.zero,
                child: recentActivityAsync.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return const Center(child: Text('No recent activity.'));
                    }
                    return ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return RecentActivityTile(activity: activity);
                      },
                    );
                  },
                  loading: () => const Center(child: ProgressRing()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A helper widget for the "At a Glance" stats
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color ?? Colors.grey[100]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FluentTheme.of(context).typography.caption,
                ),
                Text(
                  value,
                  style: FluentTheme.of(context).typography.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A helper widget to display a single recent ledger entry
class RecentActivityTile extends StatelessWidget {
  final LedgerWithFarmer activity;
  const RecentActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final ledger = activity.ledgerEntry;
    final farmer = activity.farmer;
    final isDebit = ledger.amount < 0; // Purchase
    final amountInRupees = (ledger.amount.abs() / 100).toStringAsFixed(2);
    final formattedDate = DateFormat('d MMM, yyyy').format(ledger.createdAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDebit ? Colors.red.lighter : Colors.green.lighter,
        child: Icon(
          isDebit ? FluentIcons.arrow_down_right8 : FluentIcons.arrow_up_right8,
          color: isDebit ? Colors.red.darkest : Colors.green.darkest,
        ),
      ),
      title: Text(
        '${isDebit ? 'Purchase' : 'Payment'} - ${farmer.name}',
      ),
      subtitle: Text(
        '${ledger.notes ?? 'No details'} • $formattedDate',
      ),
      trailing: Text(
        '${isDebit ? '-' : '+'}₹$amountInRupees',
        style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
          color: isDebit ? Colors.red.dark : Colors.green.dark,
        ),
      ),
    );
  }
}

