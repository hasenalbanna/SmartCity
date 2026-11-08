import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/community_issue_service.dart';
import '../theme/app_colors.dart';
import 'community_issues_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'smart_bus_tracking_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  /// Allows child screens to switch the active primary navigation tab:
  /// 0 = Home, 1 = Reports, 2 = Smart Bus, 3 = Profile
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
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
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
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.report_problem_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.report_problem_rounded),
                  ),
                  label: const Text('Reports'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.directions_bus_outlined),
                  selectedIcon: Icon(Icons.directions_bus_filled_rounded),
                  label: Text('Smart Bus'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.report_problem_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.report_problem_rounded),
              ),
              label: 'Reports',
            ),
            const NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus_filled_rounded),
              label: 'Smart Bus',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
