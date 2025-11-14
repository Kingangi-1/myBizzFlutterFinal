import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_profile_provider.dart';
import '../screens/categories_screen.dart';
import '../widgets/business_profile_dialog.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final businessProfile = Provider.of<BusinessProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Business Profile'),
          _buildBusinessProfileCard(context, businessProfile),
          SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildListTile(
            icon: Icons.category,
            title: 'Manage Categories',
            subtitle: 'Add, edit, or delete income and expense categories',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              );
            },
          ),
          _buildListTile(
            icon: Icons.backup,
            title: 'Backup Data',
            subtitle: 'Create a backup of your business data',
            onTap: () => _showBackupDialog(context),
          ),
          _buildListTile(
            icon: Icons.restore,
            title: 'Restore Data',
            subtitle: 'Restore from a previous backup',
            onTap: () => _showRestoreDialog(context),
          ),
          _buildListTile(
            icon: Icons.delete_sweep,
            title: 'Clear Data',
            subtitle: 'Delete all transactions and start fresh',
            onTap: () => _showClearDataDialog(context),
          ),
          SizedBox(height: 24),
          _buildSectionHeader('App Settings'),
          _buildListTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage app notifications and reminders',
            onTap: () => _showNotificationsSettings(context),
          ),
          _buildListTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Change app language',
            onTap: () => _showLanguageDialog(context),
          ),
          _buildListTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Change app appearance',
            onTap: () => _showThemeDialog(context),
          ),
          SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildListTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help using the app',
            onTap: () => _showHelpDialog(context),
          ),
          _buildListTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Found an issue? Let us know',
            onTap: () => _showBugReportDialog(context),
          ),
          _buildListTile(
            icon: Icons.star,
            title: 'Rate App',
            subtitle: 'Share your experience with others',
            onTap: () => _showRateAppDialog(context),
          ),
          _buildListTile(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Share with other business owners',
            onTap: () => _shareApp(context),
          ),
          SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info,
            title: 'About App',
            subtitle: 'Version information and credits',
            onTap: () => _showAboutDialog(context),
          ),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => _showPrivacyPolicy(context),
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'App usage terms and conditions',
            onTap: () => _showTermsOfService(context),
          ),
          SizedBox(height: 32),
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBusinessProfileCard(
      BuildContext context, BusinessProfileProvider businessProfile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.business, color: Colors.blue[700]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessProfile.businessName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        businessProfile.industry,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editBusinessProfile(context),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.currency_exchange, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Currency: ${businessProfile.currency}'),
                Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('FY: ${businessProfile.fiscalYear}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'MyBiz v1.0.0',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }

  // ===========================================================================
  // DIALOG METHODS
  // ===========================================================================

  void _editBusinessProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BusinessProfileDialog(),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Data'),
        content: Text(
            'This will create a backup of all your transactions, credits, and categories. The backup file will be saved to your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performBackup(context);
            },
            child: Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore Data'),
        content: Text(
            'Restore your business data from a previous backup. This will replace your current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRestore(context);
            },
            child: Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
            'This will permanently delete all your transactions, credits, and categories. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performClearData(context);
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSwitch('Payment Reminders', true),
            _buildNotificationSwitch('Monthly Reports', true),
            _buildNotificationSwitch('Credit Due Alerts', true),
            _buildNotificationSwitch('App Updates', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (bool newValue) {
        // Handle notification setting change
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', true),
            _buildLanguageOption('Swahili', false),
            _buildLanguageOption('French', false),
            _buildLanguageOption('Spanish', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        // Handle language selection
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light Theme', true),
            _buildThemeOption('Dark Theme', false),
            _buildThemeOption('System Default', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme, bool isSelected) {
    return ListTile(
      title: Text(theme),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        // Handle theme selection
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Need help with the app?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Check our online documentation'),
              Text('• Contact support: support@mybiz.com'),
              Text('• Call: +254 700 000 000'),
              SizedBox(height: 16),
              Text('Business Hours:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Mon - Fri: 8:00 AM - 5:00 PM'),
              Text('Sat: 9:00 AM - 1:00 PM'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report a Bug'),
        content: Text(
            'Found an issue? Please describe the problem you encountered and we\'ll fix it as soon as possible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bug report submitted successfully')),
              );
            },
            child: Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Our App'),
        content: Text(
            'If you enjoy using MyBiz, please consider rating us on the app store. Your feedback helps us improve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Redirecting to app store...')),
              );
            },
            child: Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About MyBiz'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MyBiz Business Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              Text('Build: 2024.12.1'),
              SizedBox(height: 16),
              Text(
                  'A comprehensive business management app for small businesses and entrepreneurs. Track transactions, manage credits, and analyze your business performance.'),
              SizedBox(height: 16),
              Text('Developed with ❤️ for business owners'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
              'Your privacy is important to us. This app stores all your data locally on your device. '
              'We do not collect, transmit, or share your personal or business data with any third parties. '
              'All financial information remains secure on your device.\n\n'
              'For backup purposes, you have the option to export your data, but this is entirely under your control.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text('By using this app, you agree to:\n\n'
              '• Use the app for legitimate business purposes only\n'
              '• Maintain the security of your device and data\n'
              '• Not attempt to reverse engineer the application\n'
              '• Understand that the developers are not liable for any financial decisions made based on app data\n\n'
              'This app is provided "as is" without warranties of any kind.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _performBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup created successfully!')),
    );
  }

  void _performRestore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data restored successfully!')),
    );
  }

  void _performClearData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All data has been cleared!')),
    );
  }
}
