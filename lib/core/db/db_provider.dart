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
final farmersStreamProvider =
StreamProvider<List<Farmer>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.farmers)
    ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});

/// =======================================
/// STOCK ITEMS STREAM PROVIDER
/// =======================================
/// Watches all stock items in real-time.
final stockStreamProvider =
StreamProvider<List<StockItem>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.stockItems)
    ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});

/// =======================================
/// LEDGER STREAM PROVIDER (✅ NEW)
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
