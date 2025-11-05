import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/db/app_db.dart';
import '../../core/db/db_provider.dart';

/// ==============================
/// 📊 Analytics Data Models
/// ==============================

/// Sales trends data model
class SalesTrends {
  final int totalSales;
  final int totalBills;
  final int totalItemsSold;
  final double averageBillValue;

  SalesTrends({
    required this.totalSales,
    required this.totalBills,
    required this.totalItemsSold,
    required this.averageBillValue,
  });
}

/// Top farmer data model
class TopFarmer {
  final int id;
  final String name;
  final int transactionCount;
  final int totalAmount;
  final int currentBalance;

  TopFarmer({
    required this.id,
    required this.name,
    required this.transactionCount,
    required this.totalAmount,
    required this.currentBalance,
  });
}

/// Stock analytics data model
class StockAnalytics {
  final int totalItems;
  final int totalStock;
  final int lowStockCount;

  StockAnalytics({
    required this.totalItems,
    required this.totalStock,
    required this.lowStockCount,
  });
}

/// Farmer statistics data model
class FarmerStats {
  final int activeFarmers;
  final int totalOutstanding;
  final double averageBalance;

  FarmerStats({
    required this.activeFarmers,
    required this.totalOutstanding,
    required this.averageBalance,
  });
}

/// ==============================
/// 📊 Analytics Providers
/// ==============================

/// Sales trends provider
final salesTrendsProvider = FutureProvider<SalesTrends>((ref) async {
  final db = ref.watch(dbProvider);
  
  // Get total sales and bill count
  final billQuery = db.select(db.bills);
  final bills = await billQuery.get();
  
  final totalSales = bills.fold<int>(0, (sum, bill) => sum + bill.totalAmount);
  final totalBills = bills.length;
  
  // Get total items sold
  final itemQuery = db.select(db.billItems);
  final items = await itemQuery.get();
  final totalItemsSold = items.fold<int>(0, (sum, item) => sum + item.quantity.toInt());
  
  // Calculate average bill value
  final averageBillValue = totalBills > 0 ? totalSales / totalBills : 0.0;
  
  return SalesTrends(
    totalSales: totalSales,
    totalBills: totalBills,
    totalItemsSold: totalItemsSold,
    averageBillValue: averageBillValue,
  );
});

/// Top farmers by transaction volume provider
final topFarmersProvider = FutureProvider<List<TopFarmer>>((ref) async {
  final db = ref.watch(dbProvider);
  
  // Get all ledger entries grouped by farmer
  final ledgerQuery = db.select(db.ledgerEntries);
  final ledgers = await ledgerQuery.get();
  
  // Group by farmer and calculate totals
  final farmerMap = <int, Map<String, dynamic>>{};
  
  for (final ledger in ledgers) {
    if (!farmerMap.containsKey(ledger.farmerId)) {
      farmerMap[ledger.farmerId] = {
        'count': 0,
        'total': 0,
      };
    }
    farmerMap[ledger.farmerId]!['count'] = 
        (farmerMap[ledger.farmerId]!['count'] as int) + 1;
    farmerMap[ledger.farmerId]!['total'] = 
        (farmerMap[ledger.farmerId]!['total'] as int) + ledger.amount.abs();
  }
  
  // Get farmer details
  final farmerQuery = db.select(db.farmers);
  final farmers = await farmerQuery.get();
  
  final topFarmers = <TopFarmer>[];
  for (final farmer in farmers) {
    if (farmerMap.containsKey(farmer.id)) {
      topFarmers.add(TopFarmer(
        id: farmer.id,
        name: farmer.name,
        transactionCount: farmerMap[farmer.id]!['count'] as int,
        totalAmount: farmerMap[farmer.id]!['total'] as int,
        currentBalance: farmer.currentBalance,
      ));
    }
  }
  
  // Sort by total amount and return top 5
  topFarmers.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return topFarmers.take(5).toList();
});

/// Stock analytics provider
final stockAnalyticsProvider = FutureProvider<StockAnalytics>((ref) async {
  final db = ref.watch(dbProvider);
  
  final stockQuery = db.select(db.stockItems);
  final items = await stockQuery.get();
  
  final totalItems = items.length;
  final totalStock = items.fold<int>(0, (sum, item) => sum + item.currentStock);
  
  // Count items with low stock (less than 10 kg as threshold)
  final lowStockThreshold = 10;
  final lowStockCount = items.where((item) => item.currentStock < lowStockThreshold).length;
  
  return StockAnalytics(
    totalItems: totalItems,
    totalStock: totalStock,
    lowStockCount: lowStockCount,
  );
});

/// Farmer statistics provider
final farmerStatsProvider = FutureProvider<FarmerStats>((ref) async {
  final db = ref.watch(dbProvider);
  
  final farmerQuery = db.select(db.farmers);
  final farmers = await farmerQuery.get();
  
  final activeFarmers = farmers.length;
  final totalOutstanding = farmers.fold<int>(0, (sum, farmer) => sum + farmer.currentBalance);
  final averageBalance = activeFarmers > 0 ? (totalOutstanding / activeFarmers).toDouble() : 0.0;
  
  return FarmerStats(
    activeFarmers: activeFarmers,
    totalOutstanding: totalOutstanding,
    averageBalance: averageBalance,
  );
});

/// Low stock items provider (items with less than 10 kg)
final lowStockItemsProvider = FutureProvider<List<StockItem>>((ref) async {
  final db = ref.watch(dbProvider);
  
  final lowStockThreshold = 10;
  final query = db.select(db.stockItems)
    ..where((tbl) => tbl.currentStock.isSmallerThanValue(lowStockThreshold))
    ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.currentStock)]);
  
  return await query.get();
});

/// Recent bills provider (last 10 bills)
final recentBillsProvider = FutureProvider<List<Bill>>((ref) async {
  final db = ref.watch(dbProvider);
  
  final query = db.select(db.bills)
    ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.createdAt)])
    ..limit(10);
  
  return await query.get();
});

/// Monthly sales trend provider (last 6 months)
final monthlySalesTrendProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(dbProvider);
  
  final billQuery = db.select(db.bills);
  final bills = await billQuery.get();
  
  // Group bills by month
  final monthlyData = <String, int>{};
  final now = DateTime.now();
  
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    monthlyData[monthKey] = 0;
  }
  
  for (final bill in bills) {
    final monthKey = '${bill.createdAt.year}-${bill.createdAt.month.toString().padLeft(2, '0')}';
    if (monthlyData.containsKey(monthKey)) {
      monthlyData[monthKey] = monthlyData[monthKey]! + bill.totalAmount;
    }
  }
  
  return monthlyData;
});
