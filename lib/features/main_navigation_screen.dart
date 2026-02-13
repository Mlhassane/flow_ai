import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/features/home/home_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow/features/tutor/tutor_screen.dart';
import 'package:flow/features/profile/profile_screen.dart';
import 'package:flow/features/library/library_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LibraryScreen(),
    const TutorScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.book_rounded, label: 'Mes Quiz'),
    NavItem(icon: Icons.chat_bubble_rounded, label: 'Tuteur'),
    NavItem(icon: Icons.home_rounded, label: 'Réviser'),
    NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 10
                  : 30,
              child: _buildGlassNavBar(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 20) / _navItems.length;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Sliding Indicator (Subtle Pill)
                  AnimatedPositioned(
                    duration: 300.ms,
                    curve: Curves.easeInOut,
                    left: 10 + (_currentIndex * itemWidth),
                    child: Container(
                      width: itemWidth,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Nav Items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      _navItems.length,
                      (index) => _buildNavItem(index, isDark, itemWidth),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark, double width) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3)),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3)),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}
