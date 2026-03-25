import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/contribution.dart';
import '../../services/api_service.dart';

class MemberDetailScreen extends StatefulWidget {
  final User member;
  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<List<Contribution>> _contributionsFuture;

  @override
  void initState() {
    super.initState();
    _contributionsFuture = ApiService().getAllContributions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.member.fullName)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _contributionsFuture = ApiService().getAllContributions();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF1976D2),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                widget.member.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.member.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text('Rôle: ${widget.member.role}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Historique des Contributions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FutureBuilder<List<Contribution>>(
                future: _contributionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune contribution trouvée.'));
                  }

                  final memberContributions = snapshot.data!.where((c) {
                    if (c.member is User) {
                      return (c.member as User).id == widget.member.id;
                    } else if (c.member is String) {
                      return c.member == widget.member.id;
                    }
                    return false;
                  }).toList();

                  if (memberContributions.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Ce membre n\'a pas encore de contributions.', textAlign: TextAlign.center),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: memberContributions.length,
                    itemBuilder: (context, index) {
                      final contrib = memberContributions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.attach_money, color: Colors.white),
                          ),
                          title: Text('${contrib.amount} FCFA'),
                          subtitle: Text('${contrib.type} - ${DateFormat('dd/MM/yyyy', 'fr').format(contrib.date)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: contrib.status == 'Payé' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              contrib.status,
                              style: TextStyle(
                                color: contrib.status == 'Payé' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
