import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:vegbill/core/services/pdf_service.dart';
import 'package:vegbill/core/services/whatsapp_service.dart';

// Provider to watch all bills
final billsStreamProvider = StreamProvider<List<BillWithFarmer>>((ref) {
  final db = ref.watch(dbProvider);
  
  final query = db.select(db.bills).join([
    innerJoin(db.farmers, db.farmers.id.equalsExp(db.bills.farmerId)),
  ])
    ..orderBy([OrderingTerm.desc(db.bills.createdAt)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return BillWithFarmer(
        bill: row.readTable(db.bills),
        farmer: row.readTable(db.farmers),
      );
    }).toList();
  });
});

class BillWithFarmer {
  final Bill bill;
  final Farmer farmer;

  BillWithFarmer({required this.bill, required this.farmer});
}

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Bills & Invoices',
                style: FluentTheme.of(context).typography.title,
              ),
              InfoLabel(
                label: 'Use the actions to download PDFs or send via WhatsApp',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bills List
          Expanded(
            child: billsAsync.when(
              data: (bills) {
                if (bills.isEmpty) {
                  return const Center(
                    child: Text('No bills found. Create a bill to see it here.'),
                  );
                }
                return ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final billData = bills[index];
                    final bill = billData.bill;
                    final farmer = billData.farmer;
                    final dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');
                    
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bill.status == 'PAID' 
                              ? Colors.green.lighter 
                              : Colors.orange.lighter,
                          child: Text(
                            '#${bill.id}',
                            style: TextStyle(
                              color: bill.status == 'PAID' 
                                  ? Colors.green.darkest 
                                  : Colors.orange.darkest,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          farmer.name,
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 ${dateFormat.format(bill.createdAt)}'),
                            Text(
                              'Status: ${bill.status}',
                              style: TextStyle(
                                color: bill.status == 'PAID' 
                                    ? Colors.green.dark 
                                    : Colors.orange.dark,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Amount',
                                  style: FluentTheme.of(context).typography.caption,
                                ),
                                Text(
                                  '₹${(bill.totalAmount / 100).toStringAsFixed(2)}',
                                  style: FluentTheme.of(context).typography.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(FluentIcons.page),
                              onPressed: () async {
                                await _downloadPdf(context, ref, bill.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(FluentIcons.chat, color: Colors.green),
                              onPressed: () async {
                                await _sendWhatsApp(context, ref, bill, farmer);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: ProgressRing()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, int billId) async {
    // Get full invoice data first
    final db = ref.read(dbProvider);
    final invoice = await db.getFullInvoiceById(billId);
    
    if (invoice == null) {
      if (context.mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('Error'),
            content: const Text('Bill not found'),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
      return;
    }

    // Generate PDF in background
    try {
      final file = await PdfService.generateBillPdf(invoice);

      // Show success message
      if (context.mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('PDF Generated'),
            content: Text('Saved to: ${file.path}'),
            severity: InfoBarSeverity.success,
            action: Button(
              child: const Text('Open Folder'),
              onPressed: () async {
                try {
                  await Process.run('explorer', ['/select,', file.path]);
                } catch (e) {
                  // Ignore errors
                }
              },
            ),
            onClose: close,
          );
        });
      }
    } catch (e) {
      if (context.mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('Error'),
            content: Text('Failed to generate PDF: ${e.toString()}'),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    }
  }

  Future<void> _sendWhatsApp(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
    Farmer farmer,
  ) async {
    try {
      final success = await WhatsAppService.sendBillNotification(
        farmerName: farmer.name,
        phoneNumber: farmer.mobileNumber,
        billId: bill.id,
        totalAmount: bill.totalAmount / 100,
      );

      if (context.mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: Text(success ? '✅ WhatsApp Opened' : '❌ Failed'),
            content: Text(
              success
                  ? 'WhatsApp opened. You can now send the message.'
                  : 'Could not open WhatsApp. Please check the phone number.',
            ),
            severity: success ? InfoBarSeverity.success : InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    } catch (e) {
      if (context.mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('❌ Error'),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    }
  }
}
