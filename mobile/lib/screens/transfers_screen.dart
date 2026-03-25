import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/theme.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _transfers = [];

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    setState(() => _isLoading = true);
    try {
      final role = Provider.of<AuthProvider>(context, listen: false).role;
      if (role == 'Admin' || role == 'Tresorier') {
        _transfers = await _apiService.getTransferRequests();
      } else {
        _transfers = await _apiService.getMyTransfers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.primaryDark),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.updateTransferStatus(id, status);
      await _loadTransfers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour : $status'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRequestModal() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demander un virement', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entrez le montant que vous souhaitez retirer.'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Montant (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(amountController.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  await _apiService.createTransferRequest(val);
                  await _loadTransfers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demande envoyée avec succès'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur d\'envoi'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;
    final isAdminOrTresorier = role == 'Admin' || role == 'Tresorier';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Virements'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransfers,
              child: _transfers.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Aucune demande de virement trouvée.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transfers.length,
                      itemBuilder: (context, index) {
                        final t = _transfers[index];
                        final member = t['member'];
                        final memberName = member != null
                            ? '${member['firstName']} ${member['lastName']}'
                            : 'Membre supprimé';
                        
                        final amount = t['amount'];
                        final status = t['status'] ?? 'En attente';
                        final date = t['date'] != null
                            ? DateFormat('dd/MM/yyyy', 'fr').format(DateTime.parse(t['date']))
                            : 'Date inconnue';

                        Color badgeColor = Colors.orange;
                        if (status == 'Approuvé') badgeColor = Colors.green;
                        if (status == 'Rejeté') badgeColor = Colors.red;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isAdminOrTresorier ? memberName : 'Ma Demande',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      '${amount.toString()} FCFA',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: badgeColor),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isAdminOrTresorier && status == 'En attente') ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _updateStatus(t['_id'], 'Rejeté'),
                                        icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                        label: const Text('Rejeter', style: TextStyle(color: Colors.red)),
                                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _updateStatus(t['_id'], 'Approuvé'),
                                        icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                        label: const Text('Approuver'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: !isAdminOrTresorier
          ? FloatingActionButton.extended(
              onPressed: _showRequestModal,
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
              label: const Text('Demander un virement', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
