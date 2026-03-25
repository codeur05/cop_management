import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _navigate(String role) {
    if (role == 'Admin') {
      Navigator.of(context).pushReplacementNamed('/admin-dashboard');
    } else if (role == 'Tresorier') {
      Navigator.of(context).pushReplacementNamed('/tresorier-dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/member-dashboard');
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_isLogin) {
        final result = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          if (result['success']) {
            _navigate(authProvider.role ?? 'Membre');
          } else {
            final message = result['message'] ?? 'Erreur de connexion';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                action: message.contains('vérifier votre email')
                    ? SnackBarAction(
                        label: 'Vérifier',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(email: _emailController.text.trim()),
                            ),
                          );
                        },
                      )
                    : null,
              ),
            );
          }
        }
      } else {
        final result = await authProvider.register(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compte créé ! Veuillez vérifier votre email.'),
                backgroundColor: Colors.blue,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(email: _emailController.text.trim()),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Erreur'), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 12,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, AppTheme.secondaryColor],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.shield_outlined, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Digital Cooperative\nManagement',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Gérez vos contributions et restez connecté à votre coopérative en toute sécurité.',
                          style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 10,
            child: Container(
              color: AppTheme.backgroundGrey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isDesktop) ...[
                                const Center(
                                  child: Icon(Icons.shield_outlined, size: 64, color: AppTheme.primaryBlue),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Digital Cooperative Management',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 32),
                              ],

                              // Tabs
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: _TabButton(title: 'Connexion', isActive: _isLogin, onTap: () => setState(() => _isLogin = true))),
                                    Expanded(child: _TabButton(title: 'Inscription', isActive: !_isLogin, onTap: () => setState(() => _isLogin = false))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              if (!_isLogin) ...[
                                Row(
                                  children: [
                                    Expanded(child: _buildTextField(label: 'Prénom', controller: _firstNameController, icon: Icons.person_outline)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextField(label: 'Nom', controller: _lastNameController, icon: Icons.person_outline)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],

                              _buildTextField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, isEmail: true),
                              const SizedBox(height: 20),
                              _buildTextField(label: 'Mot de passe', controller: _passwordController, icon: Icons.lock_outline, isObscure: true),
                              const SizedBox(height: 32),

                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.secondaryColor]),
                                      boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16)),
                                      child: auth.isLoading
                                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(_isLogin ? Icons.login : Icons.person_add_outlined),
                                                const SizedBox(width: 12),
                                                Text(_isLogin ? 'Se connecter' : 'Créer un compte',
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),
                              Center(
                                child: InkWell(
                                  onTap: () => setState(() => _isLogin = !_isLogin),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 15),
                                      children: [
                                        TextSpan(text: _isLogin ? "Pas de compte ? " : "Déjà membre ? "),
                                        TextSpan(
                                          text: _isLogin ? "S'inscrire" : "Se connecter",
                                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, bool isEmail = false, bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textGrey),
            hintText: label,
            hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? AppTheme.primaryBlue : AppTheme.textGrey),
          ),
        ),
      ),
    );
  }
}
