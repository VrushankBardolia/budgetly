import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/button.dart';
import '../../provider/AuthProvider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _fullName = 'Loading...';
  String _email = '';
  String _phone = '';
  String _usingSince = '';

  bool _isLoading = true;

  final Color _backgroundColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _dangerColor = const Color(0xFFCF6679);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = context.read<AuthProvider>().user;
    if (user?.uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    String monthName(int month) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[month - 1];
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _fullName = data?['name'] ?? 'User';
          _email = data?['email'] ?? 'No Email';
          _phone = data?['phone'] ?? '';
          final Timestamp? ts = data?['createdAt'];
          _usingSince = ts != null
              ? "Using since ${monthName(ts.toDate().month)} ${ts.toDate().year}"
              : '';

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  void _changePhone() {
    HapticFeedback.heavyImpact();
    final controller = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Change Phone",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final user = context.read<AuthProvider>().user;
                if (user == null) return;

                final newPhone = controller.text.trim();

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.email)
                    .update({'phone': newPhone});

                setState(() => _phone = newPhone);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Phone number is updated successfully!"),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeIn,
        child: _isLoading
            ? ShimmerLoader()
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Profile"),
                    _buildSettingsTile(
                      icon: HugeIcons.strokeRoundedMail02,
                      title: _email,
                    ),

                    _buildSettingsTile(
                      icon: HugeIcons.strokeRoundedCall02,
                      title: _phone,
                      onTap: _changePhone,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Support"),
                    _buildSettingsTile(
                      icon: HugeIcons.strokeRoundedFile02,
                      title: "About Budgetly",
                      onTap: () => _showAboutAppDialog(),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Account"),
                    _buildSettingsTile(
                      icon: HugeIcons.strokeRoundedLogoutSquare01,
                      title: "Sign Out",
                      color: _dangerColor,
                      isDestructive: true,
                      onTap: _handleSignOut,
                    ),
                    const SizedBox(height: 40),

                    Text(
                      "Version 1.0.0",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              _getInitials(_fullName),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(_usingSince),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: _primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required dynamic icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
    bool isDestructive = false,
  }) {
    final iconColor = color ?? Colors.white;
    final textColor = isDestructive ? _dangerColor : Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? _dangerColor.withValues(alpha: 0.1)
                : _backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: HugeIcon(icon: icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: ((onTap != () {}) || (onTap != null))
            ? Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[600],
                size: 24,
              )
            : null,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.heavyImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  void _showAboutAppDialog() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wallet,
                size: 56,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Budgetly",
              style: TextStyle(
                fontFamily: 'BBH Bogle',
                fontSize: 32,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),

            Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            Text(
              "A simple and effective personal expense tracking application designed to help you save money.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            Button(onClick: () => Navigator.pop(context), child: Text("Close")),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  final Color _baseColor = const Color(0xFF1E1E1E);
  final Color _highlightColor = const Color(0xFF2C2C2C);
  final Color _backgroundColor = const Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Shimmer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Name and Date lines
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 160, height: 24, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Profile
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 20),

              // Section 2: Support
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 20),

              // Section 3: Account
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 40),

              // Version Text
              Center(
                child: Container(width: 80, height: 12, color: _baseColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Container(width: 80, height: 16, color: Colors.white),
    );
  }

  Widget _buildTileShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 64, // Matches approx height of your settings tile
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(child: Container(height: 16, color: _backgroundColor)),
          const SizedBox(width: 16),
          // Chevron placeholder
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
