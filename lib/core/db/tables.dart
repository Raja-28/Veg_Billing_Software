import 'package:drift/drift.dart';

/// ===========================
/// FARMERS TABLE
/// ===========================
@DataClassName('Farmer')
class Farmers extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get mobileNumber =>
      text().withLength(min: 10, max: 15)(); // Primary contact

  TextColumn get address => text().nullable()();

  /// Balance stored in **paisa** (int) to prevent float rounding issues
  IntColumn get currentBalance => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)(); // Auto timestamp
}

/// ===========================
/// STOCK ITEMS TABLE
/// ===========================
@DataClassName('StockItem')
class StockItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Name of the item (e.g., "Tomato")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Unit (e.g., "KG", "Bundle", "Piece")
  TextColumn get unit => text().withLength(min: 1, max: 20)();

  /// Current available quantity (in units)
  IntColumn get currentStock => integer().withDefault(const Constant(0))();

  /// Average purchase price (optional, helps in cost analysis)
  IntColumn get avgPurchasePrice => integer().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// ===========================
/// LEDGER ENTRIES TABLE
/// ===========================
@DataClassName('LedgerEntry')
class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Link to Farmer (foreign key)
  IntColumn get farmerId => integer().customConstraint(
    'NOT NULL REFERENCES farmers(id) ON DELETE CASCADE',
  )();

  /// Type of transaction: PURCHASE / PAYMENT / RETURN / ADJUSTMENT
  TextColumn get type => text().withLength(min: 1, max: 50)();

  /// Positive = credit, Negative = debit (in paisa)
  IntColumn get amount => integer()();

  /// Farmer’s balance after this transaction
  IntColumn get newBalance => integer()();

  /// Additional information
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// ===========================
/// BILLS TABLE
/// ===========================
@DataClassName('Bill')
class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Linked to Farmer
  IntColumn get farmerId => integer().customConstraint(
    'NOT NULL REFERENCES farmers(id) ON DELETE CASCADE',
  )();

  /// Total bill amount (in paisa)
  IntColumn get totalAmount => integer()();

  /// Payment status (e.g., Pending / Paid)
  TextColumn get status =>
      text().withDefault(const Constant('PENDING'))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// ===========================
/// BILL ITEMS TABLE
/// ===========================
@DataClassName('BillItem')
class BillItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Linked to Bill
  IntColumn get billId => integer().customConstraint(
    'NOT NULL REFERENCES bills(id) ON DELETE CASCADE',
  )();

  /// Linked to Stock Item
  IntColumn get stockItemId => integer().customConstraint(
    'NOT NULL REFERENCES stock_items(id) ON DELETE CASCADE',
  )();

  /// Name (copied from stock for history)
  TextColumn get itemName => text().withLength(min: 1, max: 100)();

  /// Quantity (supports decimals, e.g., 50.5 KG)
  RealColumn get quantity => real()();

  /// Price per unit (in paisa)
  IntColumn get pricePerUnit => integer()();

  /// Total = quantity × price
  IntColumn get total => integer()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
