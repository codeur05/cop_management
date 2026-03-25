import 'package:flutter/material.dart';
import '../../models/contribution.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class ContributionListScreen extends StatefulWidget {
  final bool onlyMine;
  const ContributionListScreen({super.key, this.onlyMine = false});

  @override
  State<ContributionListScreen> createState() => _ContributionListScreenState();
}

class _ContributionListScreenState extends State<ContributionListScreen> {
  final ApiService _apiService = ApiService();
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
      final contributions = widget.onlyMine 
          ? await _apiService.getMyContributions() 
          : await _apiService.getAllContributions();
      setState(() {
        _contributions = contributions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.onlyMine ? 'Mes Contributions' : 'Toutes les Contributions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _contributions.length,
                itemBuilder: (context, index) {
                  final c = _contributions[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on_outlined, color: Colors.blue),
                      title: Text('${c.amount.toStringAsFixed(0)} FCFA - ${c.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!widget.onlyMine)
                            Text(
                              c.member is User 
                                ? 'De: ${(c.member as User).firstName} ${(c.member as User).lastName}'
                                : 'Membre: ${(c.member as User).firstName} ${(c.member as User).lastName}', // Fallback if name is available elsewhere
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          Text('Status: ${c.status} | Date: ${c.date.day}/${c.date.month}/${c.date.year}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
