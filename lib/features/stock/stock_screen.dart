import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the new stock stream provider
    final stockAsyncValue = ref.watch(stockStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stock Management',
                  style: FluentTheme.of(context).typography.title),
              FilledButton(
                child: const Text('Add New Item'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddStockItemDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- STOCK LIST ---
          Expanded(
            child: stockAsyncValue.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No stock items found. Add one to get started.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Unit: ${item.unit}'),
                      trailing: Text(
                        'Stock: ${item.currentStock} ${item.unit}',
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

/// Dialog for adding a new stock item
class AddStockItemDialog extends ConsumerStatefulWidget {
  const AddStockItemDialog({super.key});

  @override
  ConsumerState<AddStockItemDialog> createState() => _AddStockItemDialogState();
}

class _AddStockItemDialogState extends ConsumerState<AddStockItemDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(dbProvider);

      final newItem = StockItemsCompanion(
        name: Value(_nameController.text),
        unit: Value(_unitController.text),
      );

      db.into(db.stockItems).insert(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add New Stock Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Align labels to left
          children: [
            // FIX: Manually add a Text widget for the label
            const Text('Item Name (e.g., Tomato)'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _nameController,
              placeholder: 'Enter vegetable name',
              validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            // FIX: Manually add a Text widget for the label
            const Text('Unit (e.g., KG, Bundle, Piece)'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _unitController,
              placeholder: 'Enter measurement unit',
              validator: (value) => (value == null || value.isEmpty) ? 'Unit is required' : null,
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save Item'),
        ),
      ],
    );
  }
}

