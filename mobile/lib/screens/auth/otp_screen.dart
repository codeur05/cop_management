import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _verify() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.verifyOtp(widget.email, _otpController.text.trim());

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email vérifié ! Vous pouvez vous connecter.'), backgroundColor: Colors.green),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Erreur de vérification'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _resend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resendOtp(widget.email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] ? 'Nouveau code envoyé !' : (result['message'] ?? 'Erreur')),
          backgroundColor: result['success'] ? Colors.blue : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFF1976D2)),
              const SizedBox(height: 24),
              const Text(
                'Vérifiez votre email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Nous avons envoyé un code à 6 chiffres à\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  hintText: 'Code OTP',
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                validator: (value) => (value == null || value.length != 6) ? 'Entrez le code à 6 chiffres' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VÉRIFIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: authProvider.isLoading ? null : _resend,
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
