import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/dashboard_screen.dart';
import 'package:edu_id_saas/screens/id_card_screen.dart';
import 'package:edu_id_saas/screens/login_screen.dart';
import 'package:edu_id_saas/screens/qr_scanner_screen.dart';
import 'package:edu_id_saas/screens/student_list_screen.dart';
import 'package:edu_id_saas/screens/student_profile_screen.dart';
import 'package:edu_id_saas/screens/subscription_screen.dart';

void main() {
  runApp(const EduIdApp());
}

class EduIdApp extends StatelessWidget {
  const EduIdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'EDU-ID SaaS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F4C81),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFCAD6E2)),
            ),
          ),
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          StudentListScreen.routeName: (_) => const StudentListScreen(),
          StudentProfileScreen.routeName: (_) => const StudentProfileScreen(),
          IdCardScreen.routeName: (_) => const IdCardScreen(),
          QrScannerScreen.routeName: (_) => const QrScannerScreen(),
          SubscriptionScreen.routeName: (_) => const SubscriptionScreen(),
        },
      ),
    );
  }
}
