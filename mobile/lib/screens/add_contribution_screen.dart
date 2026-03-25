import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddContributionScreen extends StatefulWidget {
  const AddContributionScreen({super.key});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedType = 'Cotisation';
  bool _isSubmitting = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      final apiService = ApiService();
      
      final success = await apiService.addContribution({
        'amount': double.parse(_amountController.text),
        'type': _selectedType,
        'date': DateTime.now().toIso8601String(),
        'status': 'Payé',
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution ajoutée !')));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de l\'ajout')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une Contribution')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              const Text('Type de contribution', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: ['Cotisation', 'Don'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('ENREGISTRER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
