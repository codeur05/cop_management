import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/contribution.dart';
import '../utils/theme.dart';

/// Tresorier view: per-member breakdown of contributions + transfer debts
class MemberSummaryScreen extends StatefulWidget {
  const MemberSummaryScreen({super.key});

  @override
  State<MemberSummaryScreen> createState() => _MemberSummaryScreenState();
}

class _MemberSummaryScreenState extends State<MemberSummaryScreen> {
  final ApiService _api = ApiService();
  List<User> _members = [];
  List<Contribution> _contributions = [];
  List<dynamic> _transfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getMembers(),
        _api.getAllContributions(),
        _api.getTransferRequests(),
      ]);
      setState(() {
        _members = List<User>.from(results[0]);
        _contributions = List<Contribution>.from(results[1]);
        _transfers = List.from(results[2]);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  double _memberContributions(String memberId) =>
      _contributions.where((c) => c.memberId == memberId).fold(0.0, (s, c) => s + c.amount);

  double _memberDebt(String memberId) =>
      _transfers.where((t) {
        final m = t['member'];
        final id = m is Map ? m['_id'] : m;
        return id == memberId && t['status'] == 'Approuvé';
      }).fold(0.0, (s, t) => s + ((t['amount'] ?? 0) as num).toDouble());

  int _memberContribCount(String memberId) =>
      _contributions.where((c) => c.memberId == memberId).length;

  double get _grandTotal => _contributions.fold(0.0, (s, c) => s + c.amount);
  double get _grandDebt => _transfers
      .where((t) => t['status'] == 'Approuvé')
      .fold(0.0, (s, t) => s + ((t['amount'] ?? 0) as num).toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Résumé Financial — Membres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Grand totals bar
                Container(
                  color: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TotalChip(label: 'Total Cotisations', value: '${_grandTotal.toStringAsFixed(0)} FCFA', icon: Icons.account_balance_wallet, color: Colors.green),
                      const SizedBox(width: 12),
                      _TotalChip(label: 'Total Dettes', value: '${_grandDebt.toStringAsFixed(0)} FCFA', icon: Icons.money_off_rounded, color: Colors.red),
                    ],
                  ),
                ),

                // Per-member list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAll,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _members.length,
                      itemBuilder: (ctx, i) {
                        final m = _members[i];
                        final id = m.id ?? '';
                        final contrib = _memberContributions(id);
                        final debt = _memberDebt(id);
                        final count = _memberContribCount(id);
                        return _MemberFinanceCard(
                          member: m,
                          totalContrib: contrib,
                          totalDebt: debt,
                          contribCount: count,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _TotalChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberFinanceCard extends StatelessWidget {
  final User member;
  final double totalContrib;
  final double totalDebt;
  final int contribCount;

  const _MemberFinanceCard({
    required this.member,
    required this.totalContrib,
    required this.totalDebt,
    required this.contribCount,
  });

  @override
  Widget build(BuildContext context) {
    final initial = member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?';
    final hasDebt = totalDebt > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hasDebt ? Colors.red.withValues(alpha: 0.2) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.12),
                child: Text(initial, style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(member.role, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                  ],
                ),
              ),
              if (hasDebt)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('ENCOURS', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(child: _FinStatItem(label: 'Cotisations', value: '${totalContrib.toStringAsFixed(0)} FCFA', color: Colors.green, icon: Icons.account_balance_wallet_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _FinStatItem(label: 'Nombre', value: contribCount.toString(), color: AppTheme.primaryBlue, icon: Icons.list_alt_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _FinStatItem(label: 'Dette', value: '${totalDebt.toStringAsFixed(0)} FCFA', color: hasDebt ? Colors.red : Colors.grey, icon: Icons.money_off_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _FinStatItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}
