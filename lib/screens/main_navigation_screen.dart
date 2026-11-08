import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/community_issue_service.dart';
import '../theme/app_colors.dart';
import 'civic_alerts_screen.dart';
import 'community_issues_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'smart_bus_tracking_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  /// Allows child screens to switch the active primary navigation tab.
  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
    state?.setTab(index);
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  static const List<Widget> _screens = [
    HomeScreen(),
    CommunityIssuesScreen(),
    SmartBusTrackingScreen(),
    CivicAlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final issueService = context.watch<CommunityIssueService>();
    final pendingCount = issueService.issues
        .where((i) => i.status == IssueStatus.pending)
        .length;

    final body = IndexedStack(
      index: _currentIndex,
      children: _screens,
    );

    // Responsive Shell:
    // < 600px: Material 3 NavigationBar (Bottom)
    // 600-1024px: NavigationRail (Compact)
    // > 1024px: NavigationRail (Extended)
    if (width >= 600) {
      final isExtended = width >= 1024;
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Row(
          children: [
            NavigationRail(
              extended: isExtended,
              selectedIndex: _currentIndex,
              onDestinationSelected: setTab,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.map_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.map_rounded),
                  ),
                  label: const Text('Report'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.directions_bus_outlined),
                  selectedIcon: Icon(Icons.directions_bus_filled_rounded),
                  label: Text('Transit'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications_rounded),
                  label: Text('Alerts'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Me'),
                ),
              ],
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.outline(context),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.outline(context), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: setTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.map_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.map_rounded),
              ),
              label: 'Report',
            ),
            const NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus_filled_rounded),
              label: 'Transit',
            ),
            const NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
