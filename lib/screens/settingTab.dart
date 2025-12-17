import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../provider/AuthProvider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _userEmail = doc.data()?['email'] ?? 'N/A';
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildAccountSection(context),
          const Divider(height: 32),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Account',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.email, color: Color(0xFF2196F3)),
          title: const Text('Email'),
          subtitle: Text(_userEmail),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Color(0xFF2196F3)),
          title: const Text('Sign Out'),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await context.read<AuthProvider>().signOut();
            }
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        const ListTile(
          leading: Icon(Icons.info, color: Color(0xFF2196F3)),
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description, color: Color(0xFF2196F3)),
          title: const Text('About App'),
          subtitle: const Text('Personal expense tracker'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Budgetly',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: Color(0xFF2196F3),
              ),
              children: [
                const Text(
                  'A simple and effective personal expense tracking application.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}