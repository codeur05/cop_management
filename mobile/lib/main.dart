import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_cooperative_management/providers/auth_provider.dart';
import 'package:digital_cooperative_management/screens/auth/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:digital_cooperative_management/screens/dashboard/admin_dashboard.dart';
import 'package:digital_cooperative_management/screens/dashboard/tresorier_dashboard.dart';
import 'package:digital_cooperative_management/screens/dashboard/member_dashboard.dart';
import 'package:digital_cooperative_management/utils/theme.dart';

import 'package:digital_cooperative_management/screens/transfers_screen.dart';
import 'package:digital_cooperative_management/screens/reports_screen.dart';
import 'package:digital_cooperative_management/screens/manager_contributions_screen.dart';
import 'package:digital_cooperative_management/screens/member_summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Cooperative Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/tresorier-dashboard': (context) => const TreasurerDashboard(),
        '/member-dashboard': (context) => const MemberDashboard(),
        '/transfers': (context) => const TransfersScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/manage-contributions': (context) => const ManagerContributionsScreen(),
        '/member-summary': (context) => const MemberSummaryScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      switch (authProvider.role) {
        case 'Admin':
          return const AdminDashboard();
        case 'Tresorier':
          return const TreasurerDashboard();
        default:
          return const MemberDashboard();
      }
    } else {
      return const LoginScreen();
    }
  }
}
