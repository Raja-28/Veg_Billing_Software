import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'app_db.dart';

/// =======================================
/// DATABASE PROVIDER
/// =======================================
/// Provides a single instance of [AppDatabase] throughout the app.
///
/// NOTE: We don’t use autoDispose here — the DB should live
/// for the lifetime of the app, not tied to widget lifecycles.
final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Safely close DB when app is disposed
  ref.onDispose(() {
    db.close();
  });

  return db;
});

/// =======================================
/// FARMERS STREAM PROVIDER
/// =======================================
/// Watches all farmers in real-time, ordered by name.
final farmersStreamProvider = StreamProvider<List<Farmer>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.farmers)
    ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});

/// =======================================
/// STOCK ITEMS STREAM PROVIDER
/// =======================================
/// Watches all stock items in real-time.
final stockStreamProvider = StreamProvider<List<StockItem>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.stockItems)
    ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});

/// =======================================
/// LEDGER STREAM PROVIDER
/// =======================================
/// Watches all ledger entries for a given farmer.
final ledgerStreamProvider =
StreamProvider.family<List<LedgerEntry>, int>((ref, farmerId) {
  final db = ref.watch(dbProvider);

  final query = (db.select(db.ledgerEntries)
    ..where((tbl) => tbl.farmerId.equals(farmerId))
    ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]));

  return query.watch();
});

// --- ✅ NEW PROVIDERS BELOW ---

/// =======================================
/// FARMER DETAIL PROVIDER (✅ NEW)
/// =======================================
/// Watches a SINGLE farmer by their ID.
final farmerDetailProvider =
StreamProvider.family<Farmer, int>((ref, farmerId) {
  final db = ref.watch(dbProvider);
  return (db.select(db.farmers)..where((tbl) => tbl.id.equals(farmerId)))
      .watchSingle();
});

/// =======================================
/// DASHBOARD: Total Farmer Count (✅ NEW)
/// =======================================
/// Watches the total number of farmers.
final totalFarmerCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(dbProvider);
  final countExpression = db.farmers.id.count();
  final query = db.selectOnly(db.farmers)..addColumns([countExpression]);

  // Watch the query and map the result to an integer
  return query.watchSingle().map((row) => row.read(countExpression) ?? 0);
});

/// =======================================
/// DASHBOARD: Recent Activity (✅ NEW)
/// =======================================
/// Watches the 5 most recent ledger entries with farmer names.
final recentActivityProvider = StreamProvider<List<LedgerWithFarmer>>((ref) {
  final db = ref.watch(dbProvider);
  // This uses the custom query we will add to app_db.dart
  return db.watchRecentLedgerEntries(limit: 5);
});

/// =======================================
/// INVOICE PROVIDER (✅ NEW)
/// =======================================
/// Fetches all data for a single invoice. This is a FutureProvider
/// because we only load it when a user clicks a button.
final invoiceProvider =
FutureProvider.family<FullInvoice?, int>((ref, billId) {
  final db = ref.watch(dbProvider);
  return db.getFullInvoiceById(billId);
});

