import 'dart:ui';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'community_issues_screen.dart';
import 'smart_bus_tracking_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityIssuesScreen(),
    SmartBusTrackingScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : const Color(0xFFE3EEFB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF2BC0E4).withValues(alpha: 0.12)
                        : const Color(0xFF2BC0E4).withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      _buildItem(
                        0,
                        Icons.home_outlined,
                        Icons.home,
                        'Home',
                        isDark,
                      ),
                      _buildItem(
                        1,
                        Icons.report_problem_outlined,
                        Icons.report_problem,
                        'Reports',
                        isDark,
                      ),
                      _buildItem(
                        2,
                        Icons.directions_bus_outlined,
                        Icons.directions_bus_filled,
                        'Smart Bus',
                        isDark,
                      ),
                      _buildItem(
                        3,
                        Icons.explore_outlined,
                        Icons.explore,
                        'Explore',
                        isDark,
                      ),
                      _buildItem(
                        4,
                        Icons.person_outline,
                        Icons.person,
                        'Profile',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;
    final inactiveColor = isDark
        ? const Color(0xFFE0E8F5)
        : const Color(0xFF93A5BD);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isSelected && !isDark
                ? Colors.black
                : null, // Plan black for light mode
            gradient: isSelected && isDark
                ? const LinearGradient(
                    colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 21,
                color: isSelected ? Colors.white : inactiveColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
