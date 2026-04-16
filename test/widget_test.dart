import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/main.dart';
import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/dashboard_screen.dart';
import 'package:edu_id_saas/screens/student_profile_screen.dart';

void main() {
  testWidgets('login screen renders demo roles', (WidgetTester tester) async {
    await tester.pumpWidget(const EduIdApp());

    expect(find.text('EDU-ID SaaS'), findsOneWidget);
    expect(find.text('Login as a demo role'), findsOneWidget);
    expect(find.text('Aanya Sharma'), findsOneWidget);
  });

  testWidgets('security guard dashboard shows QR attendance action', (
    WidgetTester tester,
  ) async {
    final state = AppState();
    state.loginAs(state.loginOptions.firstWhere((user) => user.id == 'u5'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QR Attendance'), findsOneWidget);
    expect(find.text('Students'), findsNothing);
  });

  testWidgets('student dashboard shows self-service actions', (
    WidgetTester tester,
  ) async {
    final state = AppState();
    state.loginAs(state.loginOptions.firstWhere((user) => user.id == 'u4'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('My Digital ID'), findsOneWidget);
    expect(find.text('QR Attendance'), findsNothing);
  });

  test('non-super-admin cannot switch schools in app state', () {
    final state = AppState();
    state.loginAs(state.loginOptions.firstWhere((user) => user.id == 'u2'));

    expect(state.currentSchool?.id, 'school_alpha');
    state.switchSchool('school_beta');

    expect(state.currentSchool?.id, 'school_alpha');
  });

  test('spoofed qr with mismatched student school is rejected', () {
    final state = AppState();
    state.loginAs(state.loginOptions.firstWhere((user) => user.id == 'u5'));

    final message = state.processQrValue('EDU-ID|school_alpha|s4');

    expect(message, contains('QR data mismatch'));
  });

  testWidgets('expired-school student cannot view profile screen', (
    WidgetTester tester,
  ) async {
    final state = AppState();
    state.loginAs(state.loginOptions.firstWhere((user) => user.id == 'u7'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          initialRoute: StudentProfileScreen.routeName,
          onGenerateRoute: (settings) {
            if (settings.name == StudentProfileScreen.routeName) {
              return MaterialPageRoute<void>(
                settings: const RouteSettings(
                  name: StudentProfileScreen.routeName,
                  arguments: 's5',
                ),
                builder: (_) => const StudentProfileScreen(),
              );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Access restricted'), findsOneWidget);
  });
}
