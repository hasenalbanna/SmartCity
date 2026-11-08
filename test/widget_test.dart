import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_city/main.dart';
import 'package:smart_city/models/community_issue.dart';
import 'package:smart_city/theme/app_theme.dart';
import 'package:smart_city/widgets/ui/ui.dart';

void main() {
  testWidgets('SmartCityApp loads LoginScreen with new design system', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartCityApp());
    await tester.pump();

    expect(find.byType(SmartCityApp), findsOneWidget);
    expect(find.text('Smart City'), findsOneWidget);
    expect(find.text('Continue as Citizen Guest'), findsOneWidget);
  });

  testWidgets('Reusable UI Component Library renders all core tokens', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: AppScaffold(
          body: ListView(
            children: [
              const SectionHeader(
                title: 'Civic Overview',
                subtitle: 'Design system verification',
              ),
              StatTile(
                label: 'Open Reports',
                value: '9',
                icon: Icons.report_problem_outlined,
                onTap: () => tapped = true,
              ),
              StatusChip.fromIssueStatus(IssueStatus.pending),
              StatusChip.fromIssueStatus(IssueStatus.inProgress),
              StatusChip.fromIssueStatus(IssueStatus.resolved),
              const AppTextField(
                label: 'Contact Number',
                hint: 'Enter phone',
                isRequired: true,
              ),
              AppButton(
                label: 'Submit Action',
                onPressed: () => tapped = true,
              ),
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing here',
                subtitle: 'Empty state verified',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Civic Overview'), findsOneWidget);
    expect(find.text('Open Reports'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Submit Action'), findsOneWidget);

    await tester.tap(find.text('Submit Action'));
    expect(tapped, isTrue);
  });
}
