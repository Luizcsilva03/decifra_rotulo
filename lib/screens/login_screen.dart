import 'package:decifra_rotulo/screens/register_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage; // <-- NOVO: Variável para guardar a mensagem de erro

  // Lógica de Login atualizada com tratamento de erro
  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Limpa erros anteriores
      });

      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        // Se o login falhar, define a mensagem de erro
        setState(() {
          _errorMessage = 'E-mail ou senha inválidos.';
          _isLoading = false;
        });
      }
      // Se o login for bem-sucedido, o AuthWrapper nos levará para a home
    }
  }

  // NOVO: Lógica para "Esqueci Minha Senha"
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recuperar Senha"),
        content: TextField(
          controller: resetEmailController,
          decoration: const InputDecoration(hintText: "Digite seu e-mail"),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.isNotEmpty) {
                _authService
                    .sendPasswordResetEmail(resetEmailController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Link de recuperação enviado para seu e-mail.')),
                );
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 20),
                const Text('Bem-vindo ao Decifra Rótulo',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // NOVO: Caixa de erro que só aparece quando necessário
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade800),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(_errorMessage!,
                                style: TextStyle(color: Colors.red.shade800))),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'E-mail', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value?.isEmpty ?? true)
                      ? 'Por favor, insira um e-mail'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Senha', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value?.isEmpty ?? true)
                      ? 'Por favor, insira uma senha'
                      : null,
                ),

                // NOVO: Botão "Esqueci minha senha"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: const Text('Esqueci minha senha'),
                  ),
                ),

                const SizedBox(height: 10),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Entrar'),
                  ),
                const SizedBox(height: 20),
                const Text("ou"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Image.asset('assets/google_logo.png', height: 24.0),
                  label: const Text('Continuar com Google'),
                  onPressed: () => _authService.signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Não tem uma conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
