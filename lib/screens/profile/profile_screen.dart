import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      // TODO: Upload image to server
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo upload coming soon!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Modern App Bar with Gradient
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppTheme.backgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                              AppTheme.secondaryColor.withValues(alpha: 0.3),
                              AppTheme.backgroundColor,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              // Profile Picture with Glow Effect
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: user.avatarUrl != null
                                            ? NetworkImage(user.avatarUrl!)
                                            : null,
                                        backgroundColor: AppTheme.backgroundColor,
                                        child: user.avatarUrl == null
                                            ? Icon(
                                                Icons.person,
                                                size: 60,
                                                color: AppTheme.primaryColor,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              AppTheme.secondaryColor,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Username with Gradient
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Campus with Icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.campus,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings, color: AppTheme.primaryColor),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.star_rounded,
                                  label: 'Trust Score',
                                  value: '${user.trustScore}',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.verified_user,
                                  label: 'Mode',
                                  value: user.mode.toUpperCase(),
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Profile Actions
                          _buildSectionTitle('Profile'),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.edit_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update your information',
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.photo_library_rounded,
                            title: 'Change Photo',
                            subtitle: 'Upload a new profile picture',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            onTap: _pickImage,
                          ),

                          const SizedBox(height: 24),

                          // Security
                          _buildSectionTitle('Security'),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.lock_rounded,
                            title: 'Setup PIN',
                            subtitle: 'Secure your account',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                            ),
                            onTap: () {
                              _showComingSoon(context, 'PIN Setup');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionCard(
                            icon: Icons.shield_rounded,
                            title: 'Privacy & Safety',
                            subtitle: 'Manage your privacy settings',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                            ),
                            onTap: () {
                              _showComingSoon(context, 'Privacy Settings');
                            },
                          ),

                          const SizedBox(height: 32),

                          // Logout Button
                          Container(
                            width: double.infinity,
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
                                onTap: () => _showLogoutDialog(context, authProvider),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
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
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$feature will be available in the next update!',
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
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
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
