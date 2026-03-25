import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/contribution.dart';
import '../../utils/theme.dart';
import '../members_list_screen.dart';
import '../transfers_screen.dart';
import '../manager_contributions_screen.dart';

class TreasurerDashboard extends StatefulWidget {
  const TreasurerDashboard({super.key});

  @override
  State<TreasurerDashboard> createState() => _TreasurerDashboardState();
}

class _TreasurerDashboardState extends State<TreasurerDashboard> {
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

  double get _total => _contributions.fold(0, (s, c) => s + c.amount);
  int get _late => _contributions.where((c) => c.status == 'En retard').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Tableau Trésorier', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
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
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondaryColor, Color(0xFF5b21b6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, child) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bonjour, ${auth.firstName ?? 'Trésorier'} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('Gestion Financière', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        Expanded(child: _FinanceStat(label: 'Fonds Total', value: '${_total.toStringAsFixed(0)} FCFA', color: AppTheme.secondaryColor, icon: Icons.account_balance_wallet)),
                        const SizedBox(width: 12),
                        Expanded(child: _FinanceStat(label: 'Membres', value: _members.length.toString(), color: AppTheme.primaryBlue, icon: Icons.people)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _FinanceStat(label: 'Cas de retard', value: _late.toString(), color: Colors.red, icon: Icons.warning_amber_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: _FinanceStat(label: 'Contributions', value: _contributions.length.toString(), color: Colors.green, icon: Icons.monetization_on_outlined)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    const Text('Actions Rapides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.add_circle_outline,
                            label: 'Ajouter\nContribution',
                            color: Colors.green,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagerContributionsScreen())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.people_outline,
                            label: 'Liste\nMembres',
                            color: AppTheme.primaryBlue,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.sync_alt_outlined,
                            label: 'Virements',
                            color: AppTheme.secondaryColor,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransfersScreen())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Recent Activity
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Activités Récentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _contributions.isEmpty
                                ? const Text('Aucune contribution enregistrée.', style: TextStyle(color: Colors.grey))
                                : Column(
                                    children: _contributions.take(6).map((c) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundGrey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.member is User
                                                    ? '${(c.member as User).firstName} ${(c.member as User).lastName}'.trim()
                                                    : 'Membre inconnu',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                Text('${c.amount.toStringAsFixed(0)} FCFA — ${c.type}', style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                                              ],
                                            ),
                                          ),
                                          _StatusBadge(status: c.status),
                                        ],
                                      ),
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
    );
  }
}

class _FinanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _FinanceStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
