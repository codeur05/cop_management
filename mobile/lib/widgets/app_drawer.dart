import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'package:digital_cooperative_management/screens/members_list_screen.dart';
import 'package:digital_cooperative_management/screens/contribution_list_screen.dart';
import 'package:digital_cooperative_management/screens/manager_contributions_screen.dart';
import 'package:digital_cooperative_management/screens/member_summary_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role ?? 'Membre';
    final fullName = authProvider.displayName;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              role,
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                style: const TextStyle(color: Color(0xFF1976D2), fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Tableau de bord'),
            onTap: () {
              Navigator.pop(context);
              if (role == 'Admin') {
                Navigator.pushReplacementNamed(context, '/admin-dashboard');
              } else if (role == 'Tresorier') {
                Navigator.pushReplacementNamed(context, '/tresorier-dashboard');
              } else {
                Navigator.pushReplacementNamed(context, '/member-dashboard');
              }
            },
          ),
          if (role == 'Admin' || role == 'Tresorier')
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Membres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MemberListScreen()));
              },
            ),
          // Tresorier gets dedicated contribution management page
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text('Contributions'),
            onTap: () {
              Navigator.pop(context);
              if (role == 'Admin' || role == 'Tresorier') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagerContributionsScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionListScreen(onlyMine: true)));
              }
            },
          ),
          if (role == 'Admin' || role == 'Tresorier')
            ListTile(
              leading: Icon(Icons.bar_chart_outlined, color: AppTheme.secondaryColor),
              title: const Text('Résumé Financier', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberSummaryScreen()));
              },
            ),
          const Divider(),
          if (role == 'Admin' || role == 'Tresorier')
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Rapports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/reports');
              },
            ),
          ListTile(
            leading: const Icon(Icons.sync_alt_outlined),
            title: const Text('Virements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/transfers');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
