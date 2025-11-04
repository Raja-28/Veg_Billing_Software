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
                    return Card(
                      child: ListTile(
                        leading: const Icon(FluentIcons.product_catalog, size: 24),
                        title: Text(item.name, style: FluentTheme.of(context).typography.bodyStrong),
                        subtitle: Text('Unit: ${item.unit}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Current Stock', style: FluentTheme.of(context).typography.caption),
                                Text(
                                  '${item.currentStock} ${item.unit}',
                                  style: FluentTheme.of(context).typography.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: item.currentStock < 10 ? Colors.red.dark : Colors.green.dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(FluentIcons.add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => UpdateStockDialog(stockItem: item, isAddition: true),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.remove),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => UpdateStockDialog(stockItem: item, isAddition: false),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => EditStockItemDialog(stockItem: item),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(FluentIcons.delete, color: Colors.red),
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => ContentDialog(
                                    title: const Text('Delete Item?'),
                                    content: Text('Are you sure you want to delete "${item.name}"?'),
                                    actions: [
                                      Button(
                                        child: const Text('Cancel'),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (result == true && context.mounted) {
                                  await ref.read(dbProvider).delete(ref.read(dbProvider).stockItems).delete(item);
                                  if (context.mounted) {
                                    displayInfoBar(context, builder: (context, close) {
                                      return InfoBar(
                                        title: const Text('✅ Deleted'),
                                        content: Text('${item.name} has been deleted.'),
                                        severity: InfoBarSeverity.success,
                                        onClose: close,
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
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

/// Dialog for editing an existing stock item
class EditStockItemDialog extends ConsumerStatefulWidget {
  final StockItem stockItem;
  const EditStockItemDialog({super.key, required this.stockItem});

  @override
  ConsumerState<EditStockItemDialog> createState() => _EditStockItemDialogState();
}

class _EditStockItemDialogState extends ConsumerState<EditStockItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _unitController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stockItem.name);
    _unitController = TextEditingController(text: widget.stockItem.unit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(dbProvider);
      
      await (db.update(db.stockItems)..where((t) => t.id.equals(widget.stockItem.id)))
        .write(
          StockItemsCompanion(
            name: Value(_nameController.text),
            unit: Value(_unitController.text),
          ),
        );
      
      if (mounted) {
        Navigator.of(context).pop();
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('✅ Updated'),
            content: const Text('Stock item has been updated.'),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Edit Stock Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Item Name'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _nameController,
              placeholder: 'Enter vegetable name',
              validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Unit'),
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
          child: const Text('Update'),
        ),
      ],
    );
  }
}

/// Dialog for updating stock quantity (add or remove)
class UpdateStockDialog extends ConsumerStatefulWidget {
  final StockItem stockItem;
  final bool isAddition;
  const UpdateStockDialog({super.key, required this.stockItem, required this.isAddition});

  @override
  ConsumerState<UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends ConsumerState<UpdateStockDialog> {
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(dbProvider);
      final quantity = int.parse(_quantityController.text);
      final newStock = widget.isAddition 
        ? widget.stockItem.currentStock + quantity
        : widget.stockItem.currentStock - quantity;

      if (newStock < 0) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('❌ Error'),
            content: const Text('Stock cannot be negative.'),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
        return;
      }
      
      await (db.update(db.stockItems)..where((t) => t.id.equals(widget.stockItem.id)))
        .write(
          StockItemsCompanion(
            currentStock: Value(newStock),
          ),
        );
      
      if (mounted) {
        Navigator.of(context).pop();
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('✅ Stock Updated'),
            content: Text('${widget.stockItem.name}: $newStock ${widget.stockItem.unit}'),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.isAddition ? 'Add Stock' : 'Remove Stock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${widget.stockItem.name}'),
            Text('Current Stock: ${widget.stockItem.currentStock} ${widget.stockItem.unit}'),
            const SizedBox(height: 16),
            Text('Quantity to ${widget.isAddition ? "Add" : "Remove"}'),
            const SizedBox(height: 4),
            TextFormBox(
              controller: _quantityController,
              placeholder: 'e.g., 10',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Quantity is required';
                final qty = int.tryParse(value);
                if (qty == null || qty <= 0) return 'Enter a valid quantity';
                return null;
              },
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
          child: Text(widget.isAddition ? 'Add' : 'Remove'),
        ),
      ],
    );
  }
}
