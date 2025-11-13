import 'package:flutter/material.dart';
import 'business_profile_screen.dart'; // ADD THIS IMPORT

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Business Settings Section
          _buildSectionHeader('Business Settings'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.business,
                title: 'Business Profile',
                subtitle: 'Manage your business information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BusinessProfileScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.category,
                title: 'Categories',
                subtitle: 'Manage income and expense categories',
                onTap: () {
                  _showComingSoonDialog(context, 'Category Management');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.contacts,
                title: 'Contacts',
                subtitle: 'Manage customers and suppliers',
                onTap: () {
                  _showComingSoonDialog(context, 'Contact Management');
                },
              ),
            ],
          ),
          SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.backup,
                title: 'Backup Data',
                subtitle: 'Create a backup of your business data',
                onTap: () {
                  _showComingSoonDialog(context, 'Data Backup');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.restore,
                title: 'Restore Data',
                subtitle: 'Restore from previous backup',
                onTap: () {
                  _showComingSoonDialog(context, 'Data Restore');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.file_download,
                title: 'Export Reports',
                subtitle: 'Export to PDF or Excel',
                onTap: () {
                  _showComingSoonDialog(context, 'Report Export');
                },
              ),
            ],
          ),
          SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader('App Preferences'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage app notifications',
                onTap: () {
                  _showComingSoonDialog(context, 'Notification Settings');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.color_lens,
                title: 'App Theme',
                subtitle: 'Light or dark mode',
                onTap: () {
                  _showComingSoonDialog(context, 'Theme Settings');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'App language settings',
                onTap: () {
                  _showComingSoonDialog(context, 'Language Settings');
                },
              ),
            ],
          ),
          SizedBox(height: 24),

          // Support Section
          _buildSectionHeader('Support'),
          _buildSettingsCard(
            children: [
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help using the app',
                onTap: () {
                  _showComingSoonDialog(context, 'Help & Support');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Share your suggestions',
                onTap: () {
                  _showComingSoonDialog(context, 'Feedback');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
          SizedBox(height: 32),

          // App Info
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Text(
          'MyBiz Manager',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '© 2024 MyBiz Project. All rights reserved.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('$feature feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About MyBiz Manager'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MyBiz Manager helps small businesses track finances, manage credits, and generate reports.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            Text('Developed for Kenyan Businesses'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
