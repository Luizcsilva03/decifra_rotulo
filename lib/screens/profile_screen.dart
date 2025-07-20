import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    // Constrói as iniciais para o avatar
    final String initials = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true
            ? user!.email![0].toUpperCase()
            : '?');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.shade100,
              child: Text(
                initials,
                style: TextStyle(fontSize: 40, color: Colors.teal.shade800),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? 'Usuário Anônimo',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'E-mail não disponível',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(), // Empurra o botão para o final
            ElevatedButton(
              onPressed: () {
                authService.signOut();
                // Fecha a tela de perfil e o AuthWrapper cuidará do resto
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white),
              child: const Text('Sair (Logout)'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
