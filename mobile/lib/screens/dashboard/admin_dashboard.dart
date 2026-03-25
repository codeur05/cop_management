import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/contribution.dart';
import '../../utils/theme.dart';
import '../contribution_list_screen.dart';
import '../add_contribution_screen.dart';
import '../members_list_screen.dart';
import '../admin_config_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  List<User> _members = [];
  List<Contribution> _contributions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final members = await _apiService.getMembers();
      final contributions = await _apiService.getAllContributions();
      setState(() {
        _members = members;
        _contributions = contributions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double get _total => _contributions.fold(0, (sum, c) => sum + c.amount);
  int get _lateCount => _contributions.where((c) => c.status == 'En retard').length;
  int get _treasurerCount => _members.where((m) => m.role == 'Tresorier').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () async {
              final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AdminConfigScreen()));
              if (ok == true) _loadData();
            }
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bonjour, ${auth.firstName ?? 'Admin'} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('Vue d\'ensemble de la coopérative', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(title: 'Total Membres', value: _members.length.toString(), icon: Icons.people, color: AppTheme.primaryBlue),
                        _StatCard(title: 'Fonds Coopérative', value: '${_total.toStringAsFixed(0)} FCFA', icon: Icons.account_balance_wallet, color: AppTheme.secondaryColor),
                        _StatCard(title: 'Alertes Retard', value: _lateCount.toString(), icon: Icons.warning_amber_rounded, color: Colors.red),
                        _StatCard(title: 'Trésoriers', value: _treasurerCount.toString(), icon: Icons.admin_panel_settings, color: AppTheme.accentColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Chart
                    if (_contributions.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Graphique des Contributions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  BarChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, m) {
                                            final labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
                                            return Text(v.toInt() < labels.length ? labels[v.toInt()] : '', style: const TextStyle(fontSize: 10));
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(6, (i) => BarChartGroupData(
                                      x: i,
                                      barRods: [BarChartRodData(
                                        toY: 50.0 + i * 30 + (i % 3) * 20,
                                        gradient: const LinearGradient(
                                          colors: [AppTheme.primaryBlue, AppTheme.secondaryColor],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        width: 20,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                      )],
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recent Members
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Derniers Membres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen())),
                                  child: const Text('Voir tout →'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._members.take(5).map((m) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                child: Text(m.firstName.isNotEmpty ? m.firstName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                              ),
                              title: Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(m.email, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                              trailing: _RoleBadge(role: m.role),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recent Contributions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Dernières Contributions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContributionListScreen())),
                                  child: const Text('Voir tout →'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _contributions.isEmpty
                                ? const Text('Aucune contribution', style: TextStyle(color: Colors.grey))
                                : Column(
                                    children: _contributions.take(5).map((c) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const CircleAvatar(backgroundColor: Color(0xFFe0f2e9), child: Icon(Icons.monetization_on, color: Colors.green)),
                                      title: Text('${c.amount.toStringAsFixed(0)} FCFA — ${c.type}'),
                                      subtitle: Text(c.status),
                                      trailing: _StatusBadge(status: c.status),
                                    )).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddContributionScreen()));
          if (ok == true) _loadData();
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Admin': Colors.red,
      'Tresorier': Colors.purple,
      'Membre': Colors.blue,
    };
    final c = colors[role] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Text(role, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c = Colors.orange;
    if (status == 'Payé') c = Colors.green;
    if (status == 'En retard') c = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Text(status, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
    );
  }
}
