import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final ApiService _apiService = ApiService();
  List<User> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _apiService.getMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRoleDialog(User member) {
    String selectedRole = member.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Rôle de ${member.firstName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            items: ['Admin', 'Tresorier', 'Membre'].map((role) => DropdownMenuItem(
              value: role,
              child: Text(role),
            )).toList(),
            onChanged: (val) => setModalState(() => selectedRole = val!),
            decoration: const InputDecoration(labelText: 'Rôle', prefixIcon: Icon(Icons.admin_panel_settings_outlined)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await _apiService.updateMemberRole(member.id!, selectedRole);
                if (mounted) {
                  await _loadMembers();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Rôle mis à jour ✅' : 'Erreur lors de la mise à jour'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(User member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce membre ?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('${member.firstName} ${member.lastName} sera supprimé définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final ok = await _apiService.deleteMember(member.id!);
              await _loadMembers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Membre supprimé' : 'Erreur suppression'),
                    backgroundColor: ok ? Colors.red : Colors.grey,
                  ),
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

  void _showAddMemberDialog() {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'Membre';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter un membre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildField(ctrl: firstNameCtrl, label: 'Prénom', icon: Icons.person_outline)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(ctrl: lastNameCtrl, label: 'Nom', icon: Icons.person_outline)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(ctrl: emailCtrl, label: 'Email', icon: Icons.email_outlined, type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildField(ctrl: passwordCtrl, label: 'Mot de passe', icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Rôle', prefixIcon: Icon(Icons.admin_panel_settings_outlined), border: OutlineInputBorder()),
                  items: ['Membre', 'Tresorier', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setModalState(() => role = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (firstNameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);
                      try {
                        await _apiService.register(firstNameCtrl.text.trim(), lastNameCtrl.text.trim(), emailCtrl.text.trim(), passwordCtrl.text.trim());
                        await _loadMembers();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membre ajouté ✅'), backgroundColor: Colors.green));
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Ajouter le membre', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController ctrl, required String label, required IconData icon, TextInputType? type, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).role == 'Admin';

    final roleColors = {'Admin': Colors.red, 'Tresorier': Colors.purple, 'Membre': Colors.blue};

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text('Membres (${_members.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMembers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMembers,
              child: _members.isEmpty
                  ? const Center(child: Text('Aucun membre trouvé'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final m = _members[index];
                        final roleColor = roleColors[m.role] ?? Colors.grey;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: roleColor.withValues(alpha: 0.15),
                                  child: Text(
                                    m.firstName.isNotEmpty ? m.firstName[0].toUpperCase() : '?',
                                    style: TextStyle(color: roleColor, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${m.firstName} ${m.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(m.email, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                        child: Text(m.role, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                                    tooltip: 'Changer le rôle',
                                    onPressed: () => _showRoleDialog(m),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'Supprimer',
                                    onPressed: () => _confirmDelete(m),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showAddMemberDialog,
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.person_add_outlined, color: Colors.white),
              label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
