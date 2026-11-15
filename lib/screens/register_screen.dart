// lib/screens/register_screen.dart

import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Ocorreu um erro desconhecido.';
      if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso por outra conta.';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca. Tente uma mais forte.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ocorreu uma falha. Tente novamente.'),
            backgroundColor: Colors.red.shade800,
          ),
        );
    }
    finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- MUDANÇA 1: AppBar mais limpa, sem título ---
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fundo transparente
        elevation: 0, // Sem sombra
        // Força o ícone de voltar a ser escuro para contrastar com o fundo branco
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- MUDANÇA 2: Novos elementos visuais adicionados ---
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    semanticLabel: 'Logo do Decifra Rótulo',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Crie sua Conta', // Título no corpo da tela
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'É rápido, fácil e grátis!', // Mensagem de incentivo
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32), // Espaçamento maior

                  // --- Campos do formulário ---
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (value) => (value?.trim().isEmpty ?? true) ? 'Por favor, insira seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value?.trim().isEmpty ?? true) ? 'Por favor, insira um e-mail' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _isLoading ? null : _submit(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => (value?.trim().length ?? 0) < 6 ? 'A senha deve ter pelo menos 6 caracteres' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Botões ---
                  if (_isLoading)
                    Semantics(
                      liveRegion: true,
                      label: 'Criando conta',
                      child: const CircularProgressIndicator(),
                    )
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cadastrar'),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Já tem uma conta? Faça login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}