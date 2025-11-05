import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_db.dart';
import 'analytics_providers.dart';

/// ==============================
/// 📊 Analytics Screen
/// ==============================
/// Comprehensive analytics dashboard with sales trends, farmer insights, and stock analytics
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Analytics'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Refresh'),
              onPressed: () {
                ref.invalidate(salesTrendsProvider);
                ref.invalidate(topFarmersProvider);
                ref.invalidate(stockAnalyticsProvider);
              },
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Time Period: '),
                const SizedBox(width: 8),
                ToggleButton(
                  checked: _selectedPeriod == 0,
                  onChanged: (checked) {
                    if (checked) setState(() => _selectedPeriod = 0);
                  },
                  child: const Text('Week'),
                ),
                const SizedBox(width: 8),
                ToggleButton(
                  checked: _selectedPeriod == 1,
                  onChanged: (checked) {
                    if (checked) setState(() => _selectedPeriod = 1);
                  },
                  child: const Text('Month'),
                ),
                const SizedBox(width: 8),
                ToggleButton(
                  checked: _selectedPeriod == 2,
                  onChanged: (checked) {
                    if (checked) setState(() => _selectedPeriod = 2);
                  },
                  child: const Text('Year'),
                ),
              ],
            ),
          ),
          
          // Tab View
          Expanded(
            child: TabView(
              currentIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
              tabs: [
                Tab(
                  text: const Text('Overview'),
                  body: _buildOverviewTab(),
                ),
                Tab(
                  text: const Text('Sales'),
                  body: _buildSalesTab(),
                ),
                Tab(
                  text: const Text('Farmers'),
                  body: _buildFarmersTab(),
                ),
                Tab(
                  text: const Text('Stock'),
                  body: _buildStockTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final salesTrends = ref.watch(salesTrendsProvider);
    final topFarmers = ref.watch(topFarmersProvider);
    final stockAnalytics = ref.watch(stockAnalyticsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Key Metrics
        Text(
          'Key Metrics',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        salesTrends.when(
          data: (trends) => _buildKeyMetricsCards(trends),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(FluentIcons.error_badge, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error loading sales data: $e'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Top Farmers
        Text(
          'Top 5 Farmers by Transaction Volume',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        topFarmers.when(
          data: (farmers) => farmers.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(FluentIcons.contact, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('No farmer data available yet'),
                          const SizedBox(height: 4),
                          const Text(
                            'Create bills to see farmer analytics',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _buildTopFarmersList(farmers),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Stock Summary
        Text(
          'Stock Summary',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        stockAnalytics.when(
          data: (analytics) => _buildStockSummary(analytics),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTab() {
    final salesTrends = ref.watch(salesTrendsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        salesTrends.when(
          data: (trends) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalesMetricsCards(trends),
              const SizedBox(height: 24),
              Text(
                'Sales Breakdown',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 12),
              _buildSalesBreakdown(trends),
            ],
          ),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildFarmersTab() {
    final topFarmers = ref.watch(topFarmersProvider);
    final farmerStats = ref.watch(farmerStatsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        farmerStats.when(
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFarmerStatsCards(stats),
              const SizedBox(height: 24),
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),
        Text(
          'Top Farmers',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        topFarmers.when(
          data: (farmers) => _buildDetailedFarmersList(farmers),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildStockTab() {
    final stockAnalytics = ref.watch(stockAnalyticsProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        stockAnalytics.when(
          data: (analytics) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStockMetricsCards(analytics),
              const SizedBox(height: 24),
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),
        Text(
          'Low Stock Alert',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        lowStockItems.when(
          data: (items) => _buildLowStockList(items),
          loading: () => const Center(child: ProgressRing()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsCards(SalesTrends trends) {
    // Check if there's any data
    if (trends.totalBills == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(FluentIcons.chart, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Sales Data Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first bill to see analytics here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Sales',
            '₹${(trends.totalSales / 100).toStringAsFixed(2)}',
            FluentIcons.money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Total Bills',
            trends.totalBills.toString(),
            FluentIcons.bill,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Bill Value',
            '₹${(trends.averageBillValue / 100).toStringAsFixed(2)}',
            FluentIcons.calculator,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesMetricsCards(SalesTrends trends) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Revenue',
                '₹${(trends.totalSales / 100).toStringAsFixed(2)}',
                FluentIcons.money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Total Bills',
                trends.totalBills.toString(),
                FluentIcons.bill,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Average Bill',
                '₹${(trends.averageBillValue / 100).toStringAsFixed(2)}',
                FluentIcons.calculator,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Items Sold',
                trends.totalItemsSold.toString(),
                FluentIcons.product,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFarmerStatsCards(FarmerStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Active Farmers',
            stats.activeFarmers.toString(),
            FluentIcons.contact,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Total Outstanding',
            '₹${(stats.totalOutstanding / 100).toStringAsFixed(2)}',
            FluentIcons.money,
            stats.totalOutstanding < 0 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Balance',
            '₹${(stats.averageBalance / 100).toStringAsFixed(2)}',
            FluentIcons.calculator,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStockMetricsCards(StockAnalytics analytics) {
    // Check if there's any stock data
    if (analytics.totalItems == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(FluentIcons.product_catalog, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No Stock Items Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add stock items to see inventory analytics',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Items',
            analytics.totalItems.toString(),
            FluentIcons.product_catalog,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Total Stock',
            '${analytics.totalStock} kg',
            FluentIcons.package,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Low Stock Items',
            analytics.lowStockCount.toString(),
            FluentIcons.warning,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: FluentTheme.of(context).typography.caption?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: FluentTheme.of(context).typography.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFarmersList(List<TopFarmer> farmers) {
    if (farmers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No farmer data available')),
        ),
      );
    }

    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: farmers.asMap().entries.map((entry) {
          final index = entry.key;
          final farmer = entry.value;
          return Column(
            children: [
              if (index > 0) const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(farmer.name),
                subtitle: Text('${farmer.transactionCount} transactions'),
                trailing: Text(
                  '₹${(farmer.totalAmount / 100).toStringAsFixed(2)}',
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedFarmersList(List<TopFarmer> farmers) {
    if (farmers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No farmer data available')),
        ),
      );
    }

    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: farmers.asMap().entries.map((entry) {
          final index = entry.key;
          final farmer = entry.value;
          final balance = farmer.currentBalance;
          final isNegative = balance < 0;
          
          return Column(
            children: [
              if (index > 0) const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(farmer.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transactions: ${farmer.transactionCount}'),
                    Text('Total: ₹${(farmer.totalAmount / 100).toStringAsFixed(2)}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Balance', style: TextStyle(fontSize: 11)),
                    Text(
                      '₹${(balance.abs() / 100).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isNegative ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockSummary(StockAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStockSummaryRow('Total Items', analytics.totalItems.toString()),
            const SizedBox(height: 8),
            _buildStockSummaryRow('Total Stock', '${analytics.totalStock} kg'),
            const SizedBox(height: 8),
            _buildStockSummaryRow(
              'Low Stock Items',
              analytics.lowStockCount.toString(),
              isWarning: analytics.lowStockCount > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSummaryRow(String label, String value, {bool isWarning = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesBreakdown(SalesTrends trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreakdownRow('Total Revenue', '₹${(trends.totalSales / 100).toStringAsFixed(2)}'),
            const Divider(),
            _buildBreakdownRow('Number of Bills', trends.totalBills.toString()),
            const Divider(),
            _buildBreakdownRow('Items Sold', trends.totalItemsSold.toString()),
            const Divider(),
            _buildBreakdownRow('Average Bill Value', '₹${(trends.averageBillValue / 100).toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: FluentTheme.of(context).typography.body),
          Text(value, style: FluentTheme.of(context).typography.bodyStrong),
        ],
      ),
    );
  }

  Widget _buildLowStockList(List<StockItem> items) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('All stock levels are healthy!')),
        ),
      );
    }

    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              if (index > 0) const Divider(),
              ListTile(
                leading: Icon(FluentIcons.warning, color: Colors.red),
                title: Text(item.name),
                subtitle: Text(
                  'Current Stock: ${item.currentStock} ${item.unit}',
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LOW',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.yellow;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
