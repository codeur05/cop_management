import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service.dart';
import '../../models/contribution.dart';
import '../../utils/theme.dart';
import '../transfers_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final ApiService _apiService = ApiService();
  List<Contribution> _myContributions = [];
  List<dynamic> _myTransfers = [];
  Map<String, dynamic>? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final contributions = await _apiService.getMyContributions();
      List<dynamic> transfers = [];
      Map<String, dynamic>? configData;
      try {
        transfers = await _apiService.getMyTransfers();
      } catch (_) {}
      try {
        configData = await _apiService.getConfig();
      } catch (_) {}
      setState(() {
        _myContributions = contributions;
        _myTransfers = transfers;
        _config = configData;
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

  double get _totalContributions => _myContributions.fold(0, (s, c) => s + c.amount);
  bool get _isLate => _myContributions.any((c) => c.status == 'En retard');

  List<dynamic> get _approvedTransfers => _myTransfers.where((t) => t['status'] == 'Approuvé').toList();
  List<dynamic> get _pendingTransfers => _myTransfers.where((t) => t['status'] == 'En attente').toList();
  double get _totalDebt => _approvedTransfers.fold(0.0, (s, t) => s + ((t['amount'] ?? 0) as num).toDouble());

  /// Next payment date = first day of next month
  String get _nextPaymentDate {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month + 1, 1);
    return DateFormat('dd MMMM yyyy', 'fr').format(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Mon Espace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
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

                    // ─── WELCOME BANNER ───────────────────────────────────
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                auth.firstName?.isNotEmpty == true ? auth.firstName![0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bonjour !', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  Text(
                                    '${auth.firstName ?? ''} ${auth.lastName ?? ''}'.trim(),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.white70, size: 12),
                                      const SizedBox(width: 4),
                                      Text('Prochain paiement : $_nextPaymentDate', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ─── CONFIGURATION OBJECTIF ───────────────────────────
                    if (_config != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Objectif : ${_config!['purpose'] ?? 'Non défini'}',
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Montant cible : ${_config!['amount'] ?? 0} FCFA',
                                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                                  ),
                                  if (_config!['dueDate'] != null)
                                    Text(
                                      'Date limite : ${DateFormat('dd MMMM yyyy', 'fr').format(DateTime.parse(_config!['dueDate']))}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ─── STATUS ────────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (_isLate ? Colors.red : Colors.green).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (_isLate ? Colors.red : Colors.green).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(_isLate ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: _isLate ? Colors.red : Colors.green, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isLate ? '⚠️ Statut : En Retard — veuillez régulariser vos cotisations.' : '✅ Statut : À jour — merci pour votre régularité !',
                              style: TextStyle(color: _isLate ? Colors.red : Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── STATS ROW ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Contributions', value: '${_totalContributions.toStringAsFixed(0)} FCFA', icon: Icons.account_balance_wallet, color: Colors.blue)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(label: 'Dette totale', value: '${_totalDebt.toStringAsFixed(0)} FCFA', icon: Icons.money_off_rounded, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Cotisations', value: _myContributions.length.toString(), icon: Icons.list_alt, color: Colors.green)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(label: 'Virements en attente', value: _pendingTransfers.length.toString(), icon: Icons.hourglass_top, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── DEBT SECTION ──────────────────────────────────────
                    if (_approvedTransfers.isNotEmpty) ...[
                      _SectionHeader(title: 'Mes Dettes de Virement', icon: Icons.money_off_rounded, color: Colors.red),
                      const SizedBox(height: 8),
                      ..._approvedTransfers.map((t) => _DebtCard(transfer: t)),
                      const SizedBox(height: 16),
                    ],

                    if (_pendingTransfers.isNotEmpty) ...[
                      _SectionHeader(title: 'Virements en Attente', icon: Icons.hourglass_top, color: Colors.orange),
                      const SizedBox(height: 8),
                      ..._pendingTransfers.map((t) => _PendingTransferCard(transfer: t)),
                      const SizedBox(height: 16),
                    ],

                    // ─── CONTRIBUTIONS ─────────────────────────────────────
                    _SectionHeader(title: 'Mes Contributions', icon: Icons.monetization_on_outlined, color: AppTheme.primaryBlue),
                    const SizedBox(height: 8),
                    _myContributions.isEmpty
                        ? const _EmptyState(message: 'Aucune contribution enregistrée')
                        : Column(
                            children: _myContributions.map((c) => _ContributionCard(c: c)).toList(),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransfersScreen())),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
        label: const Text('Demander un virement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─── WIDGETS ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final dynamic transfer;
  const _DebtCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final amount = (transfer['amount'] ?? 0) as num;
    final date = transfer['date'] != null ? DateFormat('dd/MM/yyyy', 'fr').format(DateTime.parse(transfer['date'])) : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.red, child: Icon(Icons.money_off_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Virement approuvé — ${amount.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Date : $date', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const Text('⚠️ Ce montant est dû à la coopérative', style: TextStyle(fontSize: 11, color: Colors.red)),
              ],
            ),
          ),
          const Chip(label: Text('DETTE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFFFE0E0)),
        ],
      ),
    );
  }
}

class _PendingTransferCard extends StatelessWidget {
  final dynamic transfer;
  const _PendingTransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final amount = (transfer['amount'] ?? 0) as num;
    final date = transfer['date'] != null ? DateFormat('dd/MM/yyyy', 'fr').format(DateTime.parse(transfer['date'])) : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.hourglass_top, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Virement demandé — ${amount.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('Date : $date', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const Chip(label: Text('EN ATTENTE', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFFFF3E0)),
        ],
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final Contribution c;
  const _ContributionCard({required this.c});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;
    if (c.status == 'Payé') color = Colors.green;
    if (c.status == 'En retard') color = Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.12), child: Icon(Icons.monetization_on_outlined, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c.amount.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(c.type, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Text(c.status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
