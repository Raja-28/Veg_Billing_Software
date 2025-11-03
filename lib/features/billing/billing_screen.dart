import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:vegbill/features/billing/billing_provider.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmersAsync = ref.watch(farmersStreamProvider);
    final stockAsync = ref.watch(stockStreamProvider);
    final billState = ref.watch(newBillProvider);
    final billNotifier = ref.read(newBillProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT SIDE: BILL DETAILS ---
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🧾 New Bill',
                    style: FluentTheme.of(context).typography.title),
                const SizedBox(height: 16),

                // --- FARMER SELECTOR ---
                farmersAsync.when(
                  data: (farmers) => _FarmerSelector(
                    farmers: farmers,
                    selected: billState.selectedFarmer,
                    onChanged: billNotifier.setFarmer,
                  ),
                  loading: () => const ProgressRing(),
                  error: (e, s) => Text('Error loading farmers: $e'),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // --- ITEM HEADER ---
                const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Item')),
                    Expanded(flex: 2, child: Text('Qty/Unit')),
                    Expanded(flex: 2, child: Text('Price')),
                    Expanded(flex: 2, child: Text('Total')),
                    SizedBox(width: 40),
                  ],
                ),
                const Divider(),

                // --- BILL ITEMS LIST ---
                Expanded(
                  child: billState.items.isEmpty
                      ? const Center(child: Text('No items added yet.'))
                      : ListView.builder(
                    itemCount: billState.items.length,
                    itemBuilder: (context, index) {
                      final item = billState.items[index];
                      return ListTile(
                        title: Text(item.stockItem.name),
                        subtitle: Row(
                          children: [
                            const Expanded(flex: 3, child: SizedBox()),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '${item.quantity} ${item.stockItem.unit}'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '@ ₹${item.pricePerUnit.toStringAsFixed(2)}'),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '₹${(item.totalInPaisa / 100).toStringAsFixed(2)}'),
                            ),
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: const Icon(FluentIcons.delete),
                                onPressed: () =>
                                    billNotifier.removeItem(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),
                const SizedBox(height: 12),

                // --- TOTAL & SAVE BUTTON ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL: ₹${billState.totalInRupees.toStringAsFixed(2)}',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    _SaveBillButton(
                      billNotifier: billNotifier,
                      billState: billState,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // --- RIGHT SIDE: ADD ITEM FORM ---
          Expanded(
            flex: 1,
            child: stockAsync.when(
              data: (stockItems) => _AddItemForm(stockItems: stockItems),
              loading: () => const ProgressRing(),
              error: (e, s) => Text('Error loading stock: $e'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerSelector extends StatefulWidget {
  const _FarmerSelector({
    required this.farmers,
    required this.onChanged,
    this.selected,
  });

  final List<Farmer> farmers;
  final Farmer? selected;
  final ValueChanged<Farmer> onChanged;

  @override
  State<_FarmerSelector> createState() => _FarmerSelectorState();
}

class _FarmerSelectorState extends State<_FarmerSelector> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selected?.name ?? '');
  }

  @override
  void didUpdateWidget(covariant _FarmerSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _controller.text = widget.selected?.name ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoSuggestBox<Farmer>(
      items: widget.farmers.map((f) {
        return AutoSuggestBoxItem<Farmer>(
          value: f,
          label: '${f.name} - ${f.mobileNumber}',
        );
      }).toList(),
      controller: _controller,
      onSelected: (item) => widget.onChanged(item.value!),
      placeholder: 'Select a Farmer',
    );
  }
}

/// --- ADD ITEM FORM ---
class _AddItemForm extends ConsumerStatefulWidget {
  const _AddItemForm({required this.stockItems});
  final List<StockItem> stockItems;

  @override
  ConsumerState<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends ConsumerState<_AddItemForm> {
  StockItem? _selectedStockItem;
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedStockItem != null) {
      final newItem = BillItemState(
        stockItem: _selectedStockItem!,
        quantity: double.tryParse(_qtyController.text) ?? 0,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0,
      );

      ref.read(newBillProvider.notifier).addItem(newItem);

      _formKey.currentState?.reset();
      _qtyController.clear();
      _priceController.clear();
      setState(() => _selectedStockItem = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Item to Bill'),
            const SizedBox(height: 16),
            AutoSuggestBox<StockItem>(
              items: widget.stockItems.map((item) {
                return AutoSuggestBoxItem<StockItem>(
                  value: item,
                  label: '${item.name} (${item.unit})',
                );
              }).toList(),
              onSelected: (item) {
                setState(() => _selectedStockItem = item.value);
              },
              placeholder: 'Select Stock Item',
            ),
            const SizedBox(height: 16),
            TextFormBox(
              controller: _qtyController,
              placeholder: 'e.g., 10.5',
              validator: (val) =>
              (double.tryParse(val ?? '') ?? 0) <= 0 ? 'Invalid Qty' : null,
            ),
            const SizedBox(height: 16),
            TextFormBox(
              controller: _priceController,
              placeholder: 'e.g., 20.00',
              validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                  ? 'Invalid Price'
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- SAVE BILL BUTTON ---
class _SaveBillButton extends StatefulWidget {
  final NewBillNotifier billNotifier;
  final NewBillState billState;

  const _SaveBillButton({
    required this.billNotifier,
    required this.billState,
  });

  @override
  State<_SaveBillButton> createState() => _SaveBillButtonState();
}

class _SaveBillButtonState extends State<_SaveBillButton> {
  bool _isSaving = false;

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      await widget.billNotifier.saveBill();
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text('✅ Bill Saved'),
          content: Text(
              'Bill for ${widget.billState.selectedFarmer!.name} saved successfully.'),
          severity: InfoBarSeverity.success,
          isLong: true,
          onClose: close,
        );
      });
    } catch (e) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text('❌ Failed to Save Bill'),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
          onClose: close,
        );
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = widget.billState.selectedFarmer != null &&
        widget.billState.items.isNotEmpty;

    return FilledButton(
      onPressed: (!_isSaving && canSave) ? () => _save(context) : null,
      child: _isSaving
          ? const ProgressRing()
          : const Text('💾 Save Bill'),
    );
  }
}
