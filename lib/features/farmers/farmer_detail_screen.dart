import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

/// This screen displays the transaction ledger for a single farmer.
class FarmerDetailScreen extends ConsumerWidget {
  final int farmerId;
  const FarmerDetailScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider to get the ledger entries for THIS farmer
    final ledgerAsync = ref.watch(ledgerStreamProvider(farmerId));

    // Also get the farmer's details one time to display their name
    final farmerFuture = ref.watch(dbProvider).select(ref.read(dbProvider).farmers)
      ..where((tbl) => tbl.id.equals(farmerId));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          FutureBuilder<List<Farmer>>(
              future: farmerFuture.get(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final farmer = snapshot.data!.first;
                  return Text(
                    'Ledger: ${farmer.name}',
                    style: FluentTheme.of(context).typography.title,
                  );
                }
                return const Text('Loading...', style: TextStyle());
              }
          ),
          Text(
            'A complete history of all transactions.',
            style: FluentTheme.of(context).typography.caption,
          ),
          const SizedBox(height: 16),

          // --- LEDGER LIST HEADER ---
          Row(
            children: [
              Expanded(flex: 2, child: Text('Date', style: FluentTheme.of(context).typography.bodyStrong)),
              Expanded(flex: 3, child: Text('Details', style: FluentTheme.of(context).typography.bodyStrong)),
              Expanded(flex: 2, child: Text('Debit (-)', style: FluentTheme.of(context).typography.bodyStrong, textAlign: TextAlign.right,)),
              Expanded(flex: 2, child: Text('Credit (+)', style: FluentTheme.of(context).typography.bodyStrong, textAlign: TextAlign.right,)),
              Expanded(flex: 2, child: Text('Balance', style: FluentTheme.of(context).typography.bodyStrong, textAlign: TextAlign.right,)),
            ],
          ),
          const Divider(style: DividerThemeData(horizontalMargin: EdgeInsets.zero)),

          // --- LEDGER LIST ---
          Expanded(
            child: ledgerAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(child: Text('No transactions found for this farmer.'));
                }
                // Display the list of transactions
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isDebit = entry.amount < 0;
                    final isCredit = entry.amount > 0;
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(flex: 2, child: Text(DateFormat('dd-MMM-yyyy').format(entry.createdAt))),
                          Expanded(flex: 3, child: Text(entry.notes ?? entry.type)),
                          Expanded(flex: 2, child: Text(isDebit ? '₹${(entry.amount / -100).toStringAsFixed(2)}' : '', textAlign: TextAlign.right, style: TextStyle(color: Colors.red))),
                          Expanded(flex: 2, child: Text(isCredit ? '₹${(entry.amount / 100).toStringAsFixed(2)}' : '', textAlign: TextAlign.right, style: TextStyle(color: Colors.green))),
                          Expanded(flex: 2, child: Text('₹${(entry.newBalance / 100).toStringAsFixed(2)}', textAlign: TextAlign.right, style: FluentTheme.of(context).typography.bodyStrong)),
                        ],
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(child: ProgressRing()),
            ),
          ),
        ],
      ),
    );
  }
}
