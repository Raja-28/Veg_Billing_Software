import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pin_auth_provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/db/db_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ==============================
/// ⚙️ Settings Screen
/// ==============================
/// Comprehensive settings page with security, preferences, and data management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoBackup = false;
  bool _showNotifications = true;
  bool _darkMode = false;
  String _currency = 'INR';
  int _backupFrequency = 7; // days
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = ref.read(themeModeProvider);
    setState(() {
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _showNotifications = prefs.getBool('show_notifications') ?? true;
      _darkMode = themeMode == ThemeMode.dark;
      _currency = prefs.getString('currency') ?? 'INR';
      _backupFrequency = prefs.getInt('backup_frequency') ?? 7;
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
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
          // Security Section
          _buildSectionHeader(context, 'Security', FluentIcons.shield),
          const SizedBox(height: 12),
          _buildSecuritySection(context),
          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader(context, 'Preferences', FluentIcons.settings),
          const SizedBox(height: 12),
          _buildPreferencesSection(context),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management', FluentIcons.database),
          const SizedBox(height: 12),
          _buildDataManagementSection(context),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About', FluentIcons.info),
          const SizedBox(height: 12),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: FluentTheme.of(context).typography.subtitle,
        ),
      ],
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
            subtitle: const Text('Remove current PIN (requires confirmation)'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showResetPinDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
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
                // Switch theme
                final themeNotifier = ref.read(themeModeProvider.notifier);
                await themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.ringer, size: 24),
            title: const Text('Notifications'),
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

  Widget _buildDataManagementSection(BuildContext context) {
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.cloud_upload, size: 24),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your data to a file'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showBackupDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.cloud_download, size: 24),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from a backup file'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showRestoreDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.sync, size: 24),
            title: const Text('Auto Backup'),
            subtitle: Text('Backup every $_backupFrequency days'),
            trailing: ToggleSwitch(
              checked: _autoBackup,
              onChanged: (value) {
                setState(() => _autoBackup = value);
                _savePreference('auto_backup', value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.delete, size: 24),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all app data (cannot be undone)'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showClearDataDialog(context),
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
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(FluentIcons.build_queue, size: 24),
            title: Text('Build'),
            subtitle: Text('Production'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(FluentIcons.feedback, size: 24),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve VegBill'),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => _showFeedbackDialog(context),
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
              if (mounted) {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                    title: const Text('PIN Reset'),
                    content: const Text('Your PIN has been reset successfully.'),
                    actions: [
                      FilledButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/pin-setup');
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'This feature will export all your data to a file. Choose a location to save the backup.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Export'),
            onPressed: () {
              // TODO: Implement backup functionality
              Navigator.pop(context);
              _showInfoBar(context, 'Backup feature coming soon!');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace all current data with data from a backup file. This action cannot be undone.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Choose File'),
            onPressed: () {
              // TODO: Implement restore functionality
              Navigator.pop(context);
              _showInfoBar(context, 'Restore feature coming soon!');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all farmers, bills, stock, and ledger entries. This action cannot be undone!',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Delete All'),
            onPressed: () async {
              final db = ref.read(dbProvider);
              // Clear all tables
              await db.delete(db.farmers).go();
              await db.delete(db.bills).go();
              await db.delete(db.billItems).go();
              await db.delete(db.stockItems).go();
              await db.delete(db.ledgerEntries).go();
              
              if (mounted) {
                Navigator.pop(context);
                _showInfoBar(context, 'All data cleared successfully');
              }
            },
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
              // TODO: Implement feedback submission
              Navigator.pop(context);
              _showInfoBar(context, 'Thank you for your feedback!');
            },
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
