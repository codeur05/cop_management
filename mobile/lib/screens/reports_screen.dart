import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {'types': [], 'status': []};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _apiService.getContributionStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapports Financiers')),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final types = _stats['types'] as List<dynamic>? ?? [];
    final statuses = _stats['status'] as List<dynamic>? ?? [];

    double totalAmount = 0;
    int totalCount = 0;
    for (var t in types) {
      totalAmount += (t['total'] ?? 0);
      totalCount += (t['count'] ?? 0) as int;
    }

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.red,
      Colors.green,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Rapports Financiers')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, size: 40, color: AppTheme.primaryBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Synthèse Financière', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Rapport détaillé des contributions', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statut des Paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: List.generate(statuses.length, (i) {
                            final status = statuses[i];
                            return PieChartSectionData(
                              color: colors[i % colors.length],
                              value: (status['count'] ?? 0).toDouble(),
                              title: '${status['_id']}\n${status['count']}',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tableau Récapitulatif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Table(
                      border: const TableBorder(horizontalInside: BorderSide(color: Colors.black12)),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          ],
                        ),
                        for (var t in types)
                          TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t['_id'].toString())),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t['count'].toString())),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${t['total']} FCFA', textAlign: TextAlign.right)),
                            ],
                          ),
                        TableRow(
                          children: [
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(totalCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('$totalAmount FCFA', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
