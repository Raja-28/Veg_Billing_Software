import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import all tables
import 'tables.dart';

part 'app_db.g.dart';

/// Central database for the VegBill app.
/// Includes all tables and helper queries.
@DriftDatabase(
  tables: [Farmers, StockItems, Bills, BillItems, LedgerEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  // ===========================
  // FARMER QUERIES
  // ===========================

  Future<List<Farmer>> get allFarmers => select(farmers).get();

  Future<int> addFarmer(FarmersCompanion entry) =>
      into(farmers).insert(entry);

  Future<int> updateFarmerBalance(int farmerId, int newBalance) {
    return (update(farmers)..where((t) => t.id.equals(farmerId))).write(
      FarmersCompanion(currentBalance: Value(newBalance)),
    );
  }

  Future<Farmer?> getFarmerById(int farmerId) async {
    return (select(farmers)..where((f) => f.id.equals(farmerId)))
        .getSingleOrNull();
  }

  // ===========================
  // STOCK QUERIES
  // ===========================

  Future<List<StockItem>> get allStockItems => select(stockItems).get();

  Future<int> addStockItem(StockItemsCompanion entry) =>
      into(stockItems).insert(entry);

  // ===========================
  // BILL QUERIES
  // ===========================

  Future<int> createBill(BillsCompanion bill) => into(bills).insert(bill);

  Future<int> addBillItem(BillItemsCompanion item) =>
      into(billItems).insert(item);

  // ===========================
  // LEDGER ENTRIES
  // ===========================

  Future<int> addLedgerEntry(LedgerEntriesCompanion entry) =>
      into(ledgerEntries).insert(entry);

  Stream<List<LedgerEntry>> watchLedgerByFarmer(int farmerId) {
    final query = select(ledgerEntries)
      ..where((tbl) => tbl.farmerId.equals(farmerId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]);
    return query.watch();
  }

  /// Adds a ledger entry AND updates the farmer’s balance atomically.
  Future<void> addLedgerTransaction({
    required int farmerId,
    required int amount,
    required String type,
    String? notes,
  }) async {
    await transaction(() async {
      // Get current farmer balance
      final farmer = await getFarmerById(farmerId);
      final currentBalance = farmer?.currentBalance ?? 0;
      final newBalance = currentBalance + amount;

      // Insert ledger record
      await into(ledgerEntries).insert(
        LedgerEntriesCompanion.insert(
          farmerId: farmerId,
          type: type,
          amount: amount,
          newBalance: newBalance,
          createdAt: Value(DateTime.now()), // ✅ FIXED
          notes: Value(notes),
        ),
      );


      // Update farmer balance
      await updateFarmerBalance(farmerId, newBalance);
    });
  }

  // ===========================
  // TRANSACTION WRAPPER
  // ===========================

  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction<T>(() async => await action());
}

// ===========================
// DB CONNECTION SETUP
// ===========================
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vegbill.sqlite'));
    return NativeDatabase(file);
  });
}
