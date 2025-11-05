import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pin_auth_provider.dart';
import '../../core/services/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==============================
/// ⚙️ Settings Screen
/// ==============================
/// Comprehensive settings page with essential business features
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showNotifications = true;
  bool _darkMode = false;
  String _currency = 'INR';
  
  // Shop details
  String _shopName = 'VegBill Store';
  String _shopAddress = '';
  String _shopPhone = '';
  String _shopEmail = '';
  String _shopGST = '';
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = ref.read(themeModeProvider);
    setState(() {
      _showNotifications = prefs.getBool('show_notifications') ?? true;
      _darkMode = themeMode == ThemeMode.dark;
      _currency = prefs.getString('currency') ?? 'INR';
      
      // Load shop details
      _shopName = prefs.getString('shop_name') ?? 'VegBill Store';
      _shopAddress = prefs.getString('shop_address') ?? '';
      _shopPhone = prefs.getString('shop_phone') ?? '';
      _shopEmail = prefs.getString('shop_email') ?? '';
      _shopGST = prefs.getString('shop_gst') ?? '';
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Settings'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.lock),
              label: const Text('Lock App'),
              onPressed: () {
                ref.read(authStateProvider.notifier).lock();
                context.go('/pin-lock');
              },
            ),
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shop Details Section
          _buildSectionHeader(context, 'Shop Details', FluentIcons.shop),
          const SizedBox(height: 12),
          _buildShopDetailsSection(context),
          const SizedBox(height: 24),

          // Theme Settings Section
          _buildSectionHeader(context, 'Theme Settings', FluentIcons.color_solid),
          const SizedBox(height: 12),
          _buildThemeSection(context),
          const SizedBox(height: 24),

          // Data Export Section
          _buildSectionHeader(context, 'Data Export', FluentIcons.export),
          const SizedBox(height: 12),
          _buildDataExportSection(context),
          const SizedBox(height: 24),

          // Notification Settings Section
          _buildSectionHeader(context, 'Notifications', FluentIcons.ringer),
          const SizedBox(height: 12),
          _buildNotificationSection(context),
          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader(context, 'Security', FluentIcons.shield),
          const SizedBox(height: 12),
          _buildSecuritySection(context),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About', FluentIcons.info),
          const SizedBox(height: 12),
          _buildAboutSection(context),
          const SizedBox(height: 24),

          // Help & Support Section
          _buildSectionHeader(context, 'Help & Support', FluentIcons.help),
          const SizedBox(height: 12),
          _buildHelpSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: FluentTheme.of(context).typography.subtitle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShopDetailsSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.shop, size: 24),
            title: const Text('Shop Name'),
            subtitle: Text(_shopName),
            trailing: const Icon(FluentIcons.edit),
            onPressed: () => _showEditShopDialog(context, 'Shop Name', _shopName, 'shop_name'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.location, size: 24),
            title: const Text('Address'),
            subtitle: Text(_shopAddress.isEmpty ? 'Not set' : _shopAddress),
            trailing: const Icon(FluentIcons.edit),
            onPressed: () => _showEditShopDialog(context, 'Address', _shopAddress, 'shop_address'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.phone, size: 24),
            title: const Text('Phone Number'),
            subtitle: Text(_shopPhone.isEmpty ? 'Not set' : _shopPhone),
            trailing: const Icon(FluentIcons.edit),
            onPressed: () => _showEditShopDialog(context, 'Phone', _shopPhone, 'shop_phone'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.mail, size: 24),
            title: const Text('Email'),
            subtitle: Text(_shopEmail.isEmpty ? 'Not set' : _shopEmail),
            trailing: const Icon(FluentIcons.edit),
            onPressed: () => _showEditShopDialog(context, 'Email', _shopEmail, 'shop_email'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.certificate, size: 24),
            title: const Text('GST Number'),
            subtitle: Text(_shopGST.isEmpty ? 'Not set' : _shopGST),
            trailing: const Icon(FluentIcons.edit),
            onPressed: () => _showEditShopDialog(context, 'GST Number', _shopGST, 'shop_gst'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.color_solid, size: 24),
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            trailing: ToggleSwitch(
              checked: _darkMode,
              onChanged: (value) async {
                setState(() => _darkMode = value);
                _savePreference('dark_mode', value);
                final themeNotifier = ref.read(themeModeProvider.notifier);
                await themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.money, size: 24),
            title: const Text('Currency'),
            subtitle: Text('Current: $_currency'),
            trailing: ComboBox<String>(
              value: _currency,
              items: ['INR', 'USD', 'EUR', 'GBP']
                  .map((currency) => ComboBoxItem(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _currency = value);
                  _savePreference('currency', value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataExportSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Icon(FluentIcons.excel_document, size: 24, color: Colors.green),
            title: const Text('Export to Excel'),
            subtitle: const Text('Export all expenditure data to Excel'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _exportToExcel(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(FluentIcons.pdf, size: 24, color: Colors.red),
            title: const Text('Export to PDF'),
            subtitle: const Text('Export all expenditure data to PDF'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _exportToPDF(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.download, size: 24),
            title: const Text('Export All Data'),
            subtitle: const Text('Backup complete database'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _exportAllData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.ringer, size: 24),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Show app notifications'),
            trailing: ToggleSwitch(
              checked: _showNotifications,
              onChanged: (value) {
                setState(() => _showNotifications = value);
                _savePreference('show_notifications', value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.calendar_reply, size: 24),
            title: const Text('Low Stock Alerts'),
            subtitle: const Text('Get notified when stock is low'),
            trailing: ToggleSwitch(
              checked: true,
              onChanged: (value) {
                // TODO: Implement low stock alerts
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.calendar, size: 24),
            title: const Text('Payment Reminders'),
            subtitle: const Text('Remind about pending payments'),
            trailing: ToggleSwitch(
              checked: true,
              onChanged: (value) {
                // TODO: Implement payment reminders
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.permissions, size: 24),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your security PIN'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () {
              context.push('/pin-settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.lock, size: 24),
            title: const Text('Lock App Now'),
            subtitle: const Text('Immediately lock the application'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () {
              ref.read(authStateProvider.notifier).lock();
              context.go('/pin-lock');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.reset_device, size: 24),
            title: const Text('Reset PIN'),
            subtitle: const Text('Remove current PIN'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showResetPinDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(FluentIcons.info, size: 24),
            title: Text('Version'),
            subtitle: Text('1.1.0 (Build 110)'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(FluentIcons.build_queue, size: 24),
            title: Text('Release Date'),
            subtitle: Text('November 2025'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(FluentIcons.developer_tools, size: 24),
            title: Text('Developer'),
            subtitle: Text('VegBill Team'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.page, size: 24),
            title: const Text('License'),
            subtitle: const Text('View license information'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showLicenseDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSupportSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.help, size: 24),
            title: const Text('User Guide'),
            subtitle: const Text('Learn how to use VegBill'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showUserGuide(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.feedback, size: 24),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve VegBill'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showFeedbackDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.bug, size: 24),
            title: const Text('Report a Bug'),
            subtitle: const Text('Let us know about issues'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showBugReportDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.contact, size: 24),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help from our team'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _contactSupport(context),
          ),
        ],
      ),
    );
  }

  // Dialog and Action Methods

  Future<void> _showEditShopDialog(BuildContext context, String title, String currentValue, String key) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('Edit $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your $title:'),
            const SizedBox(height: 12),
            TextBox(
              controller: controller,
              placeholder: 'Enter $title...',
              maxLines: title == 'Address' ? 3 : 1,
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Save'),
            onPressed: () async {
              final value = controller.text.trim();
              await _savePreference(key, value);
              setState(() {
                switch (key) {
                  case 'shop_name':
                    _shopName = value;
                    break;
                  case 'shop_address':
                    _shopAddress = value;
                    break;
                  case 'shop_phone':
                    _shopPhone = value;
                    break;
                  case 'shop_email':
                    _shopEmail = value;
                    break;
                  case 'shop_gst':
                    _shopGST = value;
                    break;
                }
              });
              if (context.mounted) {
                Navigator.pop(context);
                _showInfoBar(context, '$title updated successfully');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Export to Excel'),
        content: const Text(
          'This will export all expenditure data including bills, payments, and farmer transactions to an Excel file.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Export'),
            onPressed: () {
              Navigator.pop(context);
              _showInfoBar(context, 'Excel export feature coming soon!');
              // TODO: Implement Excel export using excel package
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Export to PDF'),
        content: const Text(
          'This will export all expenditure data to a PDF file with detailed reports and summaries.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Export'),
            onPressed: () {
              Navigator.pop(context);
              _showInfoBar(context, 'PDF export feature coming soon!');
              // TODO: Implement PDF export using pdf package
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Export All Data'),
        content: const Text(
          'This will create a complete backup of your database including all farmers, bills, stock, and transactions.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Export'),
            onPressed: () {
              Navigator.pop(context);
              _showInfoBar(context, 'Database export feature coming soon!');
              // TODO: Implement database backup
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showResetPinDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'Are you sure you want to reset your PIN? You will need to set up a new PIN on next launch.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Reset'),
            onPressed: () async {
              final service = ref.read(pinAuthServiceProvider);
              await service.resetPin();
              if (context.mounted) {
                Navigator.pop(context);
                _showInfoBar(context, 'PIN reset successfully');
                context.go('/pin-setup');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLicenseDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('License Information'),
        content: const SingleChildScrollView(
          child: Text(
            'VegBill - Vegetable Trading & Farmer Account Management System\n\n'
            'Copyright © 2025 VegBill Team\n\n'
            'This software is licensed for use by authorized users only.\n\n'
            'All rights reserved.',
          ),
        ),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserGuide(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('User Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quick Start Guide:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Dashboard - View business overview'),
              Text('2. New Bill - Create bills for farmers'),
              Text('3. Stock - Manage inventory'),
              Text('4. Farmers - Manage farmer accounts'),
              Text('5. Reports - View all transactions'),
              Text('6. Analytics - Business insights'),
              SizedBox(height: 16),
              Text('For detailed help, visit our documentation.'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We value your feedback! Please share your thoughts:'),
            const SizedBox(height: 12),
            TextBox(
              controller: controller,
              placeholder: 'Enter your feedback...',
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Send'),
            onPressed: () {
              Navigator.pop(context);
              _showInfoBar(context, 'Thank you for your feedback!');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showBugReportDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 12),
            TextBox(
              controller: controller,
              placeholder: 'Describe the bug...',
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Submit'),
            onPressed: () {
              Navigator.pop(context);
              _showInfoBar(context, 'Bug report submitted. Thank you!');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get in touch with our support team:'),
            const SizedBox(height: 16),
            const Text('📧 Email: support@vegbill.com'),
            const SizedBox(height: 8),
            const Text('📞 Phone: +91 1234567890'),
            const SizedBox(height: 8),
            const Text('🌐 Website: www.vegbill.com'),
          ],
        ),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showInfoBar(BuildContext context, String message) {
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(message),
        severity: InfoBarSeverity.success,
      );
    });
  }
}
