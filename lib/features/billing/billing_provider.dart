
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegbill/core/db/app_db.dart';
import 'package:vegbill/core/db/db_provider.dart';
import 'package:collection/collection.dart';

/// --- BILL ITEM STATE ---
class BillItemState {
  final StockItem stockItem;
  final double quantity;
  final double pricePerUnit; // UI value in rupees

  BillItemState({
    required this.stockItem,
    required this.quantity,
    required this.pricePerUnit,
  });

  /// Total in paisa for precision
  int get totalInPaisa => (quantity * pricePerUnit * 100).round();
}

/// --- NEW BILL STATE ---
class NewBillState {
  final Farmer? selectedFarmer;
  final List<BillItemState> items;

  const NewBillState({
    this.selectedFarmer,
    this.items = const [],
  });

  int get totalInPaisa => items.map((e) => e.totalInPaisa).sum;
  double get totalInRupees => totalInPaisa / 100;

  NewBillState copyWith({
    Farmer? selectedFarmer,
    List<BillItemState>? items,
  }) {
    return NewBillState(
      selectedFarmer: selectedFarmer ?? this.selectedFarmer,
      items: items ?? this.items,
    );
  }
}

/// --- STATE NOTIFIER ---
class NewBillNotifier extends StateNotifier<NewBillState> {
  NewBillNotifier(this.ref) : super(const NewBillState());

  final Ref ref;

  /// Select a farmer for the bill
  void setFarmer(Farmer farmer) {
    state = state.copyWith(selectedFarmer: farmer);
  }

  /// Add a new item line
  void addItem(BillItemState item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  /// Remove an item line
  void removeItem(int index) {
    final updated = List<BillItemState>.from(state.items)..removeAt(index);
    state = state.copyWith(items: updated);
  }

  /// Clear everything
  void clearBill() {
    state = const NewBillState();
  }

  /// --- SAVE BILL LOGIC ---
  Future<void> saveBill() async {
    if (state.selectedFarmer == null) {
      throw Exception('Please select a farmer.');
    }
    if (state.items.isEmpty) {
      throw Exception('Please add at least one item.');
    }

    final db = ref.read(dbProvider);
    final farmer = state.selectedFarmer!;
    final totalAmount = state.totalInPaisa;
    final newBalance = farmer.currentBalance - totalAmount; // Debit

    await db.transaction(() async {
      // 1️⃣ Create bill
      final billCompanion = BillsCompanion(
        farmerId: Value(farmer.id),
        totalAmount: Value(totalAmount),
      );
      final newBill = await db.into(db.bills).insertReturning(billCompanion);

      // 2️⃣ Insert bill items
      final billItems = state.items.map((item) {
        return BillItemsCompanion(
          billId: Value(newBill.id),
          stockItemId: Value(item.stockItem.id),
          itemName: Value(item.stockItem.name),
          quantity: Value(item.quantity),
          pricePerUnit: Value((item.pricePerUnit * 100).round()),
          total: Value(item.totalInPaisa),
        );
      }).toList();

      await db.batch((batch) {
        batch.insertAll(db.billItems, billItems);
      });

      // 3️⃣ Ledger entry
      final ledger = LedgerEntriesCompanion(
        farmerId: Value(farmer.id),
        type: const Value('PURCHASE'),
        amount: Value(-totalAmount), // Negative = debit
        newBalance: Value(newBalance),
        notes: Value('Bill #${newBill.id}'),
      );
      await db.into(db.ledgerEntries).insert(ledger);

      // 4️⃣ Update farmer balance
      await (db.update(db.farmers)..where((t) => t.id.equals(farmer.id))).write(
        FarmersCompanion(currentBalance: Value(newBalance)),
      );
    });

    // 5️⃣ Reset state
    clearBill();
  }
}

/// --- PROVIDER ---
final newBillProvider =
StateNotifierProvider.autoDispose<NewBillNotifier, NewBillState>(
      (ref) => NewBillNotifier(ref),
);
