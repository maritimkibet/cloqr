import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../match/match_screen.dart';
import '../chat/chats_screen.dart';
import '../rooms/rooms_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  final List<Widget> _screens = [
    const MatchScreen(),
    const ChatsScreen(),
    const RoomsScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.favorite_rounded,
    Icons.chat_bubble_rounded,
    Icons.qr_code_scanner_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    'Match',
    'Chats',
    'Rooms',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      _animationControllers[_currentIndex].reverse();
      _animationControllers[index].forward();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1923),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimations[index],
              child: Icon(
                _icons[index],
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _labels[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
