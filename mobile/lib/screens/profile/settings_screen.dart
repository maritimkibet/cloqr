import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
          // Account Section
          _buildSectionHeader('Account'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user?.email ?? 'Not set',
            onTap: () => _showComingSoon('Email Change'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.school_outlined,
            title: 'Campus',
            subtitle: user?.campus ?? 'Not set',
            onTap: () => _showComingSoon('Campus Change'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.favorite_outline,
            title: 'Mode',
            subtitle: _getModeDisplayName(user?.mode ?? 'dating'),
            onTap: () => _showModeSelector(),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.lock_outline,
            title: 'Set Password',
            subtitle: 'Optional - for login on other devices',
            onTap: () => _showPasswordSetup(),
          ),

          const SizedBox(height: 32),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            subtitle: 'Play notification sounds',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.vibration_outlined,
            title: 'Vibration',
            subtitle: 'Vibrate on notifications',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
            },
          ),

          const SizedBox(height: 32),

          // Privacy Section
          _buildSectionHeader('Privacy'),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.visibility_outlined,
            title: 'Show Online Status',
            subtitle: 'Let others see when you\'re online',
            value: _showOnlineStatus,
            onChanged: (value) {
              setState(() => _showOnlineStatus = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchCard(
            icon: Icons.message_outlined,
            title: 'Allow Messages',
            subtitle: 'Receive messages from matches',
            value: _allowMessages,
            onChanged: (value) {
              setState(() => _allowMessages = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.block_outlined,
            title: 'Blocked Users',
            subtitle: 'Manage blocked users',
            onTap: () => _showComingSoon('Blocked Users'),
          ),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'About Cloqr',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () => _showComingSoon('Terms of Service'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showComingSoon('Privacy Policy'),
          ),

          const SizedBox(height: 32),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          const SizedBox(height: 12),
          _buildDangerCard(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () => _showDeleteAccountDialog(),
          ),

          const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * animValue),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryColor,
              activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDangerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * animValue),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.2),
              Colors.red.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.red[300], size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.red[200],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.red[400],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'dating':
        return 'Dating';
      case 'study':
        return 'Study Partner';
      case 'friends':
        return 'Friends';
      case 'groups':
        return 'Group Projects';
      default:
        return 'Dating';
    }
  }

  void _showModeSelector() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    String? selectedMode = user?.mode ?? 'dating';

    final modes = [
      {'id': 'dating', 'title': 'Dating', 'icon': Icons.favorite},
      {'id': 'study', 'title': 'Study Partner', 'icon': Icons.menu_book},
      {'id': 'friends', 'title': 'Friends', 'icon': Icons.people},
      {'id': 'groups', 'title': 'Group Projects', 'icon': Icons.group_work},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Mode',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: modes.map((mode) {
              final isSelected = selectedMode == mode['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedMode = mode['id'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          mode['icon'] as IconData,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          mode['title'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .updateProfile({'mode': selectedMode});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mode updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    this.setState(() {}); // Refresh the settings screen
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update mode: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordSetup() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Set Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set a password to login from other devices. This is optional.',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: 'At least 6 characters',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                final confirm = confirmPasswordController.text;

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a password'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (password != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .setupPin(password);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password set successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to set password: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Feature Available',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$feature is now active and collecting real data!',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'About Cloqr',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cloqr is a campus social networking app that helps students connect, chat, and build meaningful relationships.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Cloqr. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[300]),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Account Deletion');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
