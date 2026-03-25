import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/user.dart';
import '../models/contribution.dart';
import '../utils/theme.dart';
import '../widgets/app_drawer.dart';

class ManagerContributionsScreen extends StatefulWidget {
  const ManagerContributionsScreen({super.key});

  @override
  State<ManagerContributionsScreen> createState() => _ManagerContributionsScreenState();
}

class _ManagerContributionsScreenState extends State<ManagerContributionsScreen> {
  final ApiService _api = ApiService();
  List<User> _members = [];
  List<Contribution> _contributions = [];
  bool _isLoading = true;
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final members = await _api.getMembers();
      final contributions = await _api.getAllContributions();
      setState(() {
        _members = members;
        _contributions = contributions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  List<Contribution> get _filtered {
    if (_selectedMemberId == null) return _contributions;
    return _contributions.where((c) => c.memberId == _selectedMemberId).toList();
  }

  void _showForm({Contribution? existing}) {
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    String selectedType = existing?.type ?? 'Cotisation';
    String selectedStatus = existing?.status ?? 'Payé';
    String? selectedMemberId = existing?.memberId ?? _selectedMemberId ?? (_members.isNotEmpty ? _members.first.id : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Ajouter une contribution' : 'Modifier la contribution',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Member picker
              if (existing == null) ...[
                const Text('Membre', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedMemberId,
                  items: _members.map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text('${m.firstName} ${m.lastName}'),
                  )).toList(),
                  onChanged: (v) => setModalState(() => selectedMemberId = v),
                  decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
              ],

              // Amount
              const Text('Montant (FCFA)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.monetization_on_outlined)),
              ),
              const SizedBox(height: 16),

              // Type
              const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: ['Cotisation', 'Don', 'Amende'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setModalState(() => selectedType = v!),
                decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 16),

              // Status
              const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ['Payé', 'En attente', 'En retard'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
                decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text);
                    if (amount == null) return;
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    bool ok;
                    if (existing == null) {
                      ok = await _api.addContribution({
                        'amount': amount,
                        'type': selectedType,
                        'status': selectedStatus,
                        'date': DateTime.now().toIso8601String(),
                        'member': selectedMemberId,
                      });
                    } else {
                      ok = await _api.updateContribution(existing.id!, {
                        'amount': amount,
                        'type': selectedType,
                        'status': selectedStatus,
                      });
                    }
                    if (ok) {
                      await _loadAll();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(existing == null ? 'Contribution ajoutée !' : 'Mise à jour réussie !'), backgroundColor: Colors.green),
                        );
                      }
                    } else {
                      setState(() => _isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur lors de l\'opération'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(existing == null ? 'Ajouter' : 'Modifier', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Contribution c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la contribution ?'),
        content: Text('${c.amount} FCFA — ${c.type}\nCette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await _api.deleteContribution(c.id!);
              await _loadAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contribution supprimée'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _filtered.fold(0.0, (s, c) => s + c.amount);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('Contributions — Tous Membres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll)],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Member filter
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedMemberId,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par membre',
                      prefixIcon: Icon(Icons.person_search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous les membres')),
                      ..._members.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.firstName} ${m.lastName}'))),
                    ],
                    onChanged: (v) => setState(() => _selectedMemberId = v),
                  ),
                ),

                // Summary bar
                Container(
                  color: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SummaryChip(label: 'Contributions', value: _filtered.length.toString()),
                      _SummaryChip(label: 'Total', value: '${total.toStringAsFixed(0)} FCFA'),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAll,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Aucune contribution', style: TextStyle(color: Colors.grey, fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) {
                              final c = _filtered[i];
                              Color statusColor = Colors.orange;
                              if (c.status == 'Payé') statusColor = Colors.green;
                              if (c.status == 'En retard') statusColor = Colors.red;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor.withValues(alpha: 0.15),
                                    child: Icon(Icons.monetization_on_outlined, color: statusColor),
                                  ),
                                  title: Text('${c.amount.toStringAsFixed(0)} FCFA — ${c.type}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.member is User 
                                          ? '${(c.member as User).firstName} ${(c.member as User).lastName}'
                                          : 'Membre inconnu',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                                      ),
                                      Text(
                                        '${c.date.day}/${c.date.month}/${c.date.year}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(c.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                        onPressed: () => _showForm(existing: c),
                                        tooltip: 'Modifier',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                        onPressed: () => _confirmDelete(c),
                                        tooltip: 'Supprimer',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppTheme.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
