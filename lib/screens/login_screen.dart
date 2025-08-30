// lib/screens/login_screen.dart

import 'package:decifra_rotulo/screens/register_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _errorMessage;
  bool _isPasswordVisible = false;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } on FirebaseAuthException {
        setState(() {
          _errorMessage = 'E-mail ou senha inválidos.';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Ocorreu um erro. Tente novamente.';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Recuperar Senha"),
        content: SizedBox(
          height: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Caso seja encontrado um e-mail em nossa base de dados, enviaremos um link de recuperação.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(hintText: "Digite seu e-mail"),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.isNotEmpty) {
                _authService.sendPasswordResetEmail(resetEmailController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link de recuperação enviado para seu e-mail (se ele estiver cadastrado).')),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

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
                        Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800))),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira um e-mail' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Invertemos a lógica aqui
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira uma senha' : null,
                ),

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
                    shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
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