import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:intl/intl.dart';

/// This screen displays the transaction ledger for a single farmer.
class FarmerDetailScreen extends ConsumerWidget {
  final int farmerId;
  const FarmerDetailScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider to get the ledger entries for THIS farmer
    final ledgerAsync = ref.watch(ledgerStreamProvider(farmerId));
    
    // Watch farmer details in real-time
    final farmerAsync = ref.watch(farmerDetailProvider(farmerId));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER WITH FARMER INFO ---
          farmerAsync.when(
            data: (farmer) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.name,
                          style: FluentTheme.of(context).typography.title,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📞 ${farmer.mobileNumber}',
                          style: FluentTheme.of(context).typography.body,
                        ),
                        if (farmer.address != null && farmer.address!.isNotEmpty)
                          Text(
                            '📍 ${farmer.address}',
                            style: FluentTheme.of(context).typography.caption,
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Current Balance',
                          style: FluentTheme.of(context).typography.caption,
                        ),
                        Text(
                          '₹${(farmer.currentBalance / 100).toStringAsFixed(2)}',
                          style: FluentTheme.of(context).typography.titleLarge?.copyWith(
                            color: farmer.currentBalance < 0 ? Colors.red.dark : Colors.green.dark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddPaymentDialog(farmerId: farmer.id),
                            );
                          },
                          child: const Text('💰 Add Payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: ProgressRing()),
              ),
            ),
            error: (e, s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $e'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Transaction History',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 8),

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

/// Dialog for adding a payment
class AddPaymentDialog extends ConsumerStatefulWidget {
  final int farmerId;
  const AddPaymentDialog({super.key, required this.farmerId});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final db = ref.read(dbProvider);
        final amountInRupees = double.parse(_amountController.text);
        final amountInPaisa = (amountInRupees * 100).round();

        await db.addLedgerTransaction(
          farmerId: widget.farmerId,
          amount: amountInPaisa, // Positive = credit/payment received
          type: 'PAYMENT',
          notes: _notesController.text.isEmpty ? 'Payment received' : _notesController.text,
        );

        if (mounted) {
          Navigator.of(context).pop();
          displayInfoBar(context, builder: (context, close) {
            return InfoBar(
              title: const Text('✅ Payment Added'),
              content: Text('Payment of ₹$amountInRupees recorded successfully.'),
              severity: InfoBarSeverity.success,
              onClose: close,
            );
          });
        }
      } catch (e) {
        if (mounted) {
          displayInfoBar(context, builder: (context, close) {
            return InfoBar(
              title: const Text('❌ Error'),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
              onClose: close,
            );
          });
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Amount (₹)'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _amountController,
              placeholder: 'e.g., 1000.00',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Amount is required';
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Notes (Optional)'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _notesController,
              placeholder: 'e.g., Cash payment',
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: ProgressRing(),
                )
              : const Text('Save Payment'),
        ),
      ],
    );
  }
}
