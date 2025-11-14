// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe este
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isUploading = false;
  String _appVersion = '...';
  
  // Vamos guardar o usuário no estado para fácil acesso
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser; // Pega o usuário na inicialização
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final imageFile = File(pickedFile.path);
      
      // O serviço de auth já atualiza o 'currentUser' internamente
      await _authService.uploadProfilePicture(imageFile);
      
      if (mounted) {
        // --- A CORREÇÃO MÁGICA ---
        // Forçamos um setState() que atualiza _user e _isUploading.
        // Isso fará o build() rodar de novo e ler a nova photoURL.
        setState(() {
          _user = _authService.currentUser; // Pega o usuário ATUALIZADO
          _isUploading = false;
        });
      }
    }
  }

  void _showAboutDialog() {
    // ... (Sua função _showAboutDialog está perfeita, sem mudanças)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(child: Image.asset('assets/logo.png', height: 60)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Decifra Rótulo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Versão $_appVersion"),
            const SizedBox(height: 24),
            const Text(
              "Este aplicativo utiliza a base de dados mundial e colaborativa do Open Food Facts. Nosso muito obrigado a toda a comunidade!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              child: const Text("FECHAR"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- MUDANÇA PRINCIPAL: REMOVEMOS O STREAMBUILDER ---
    
    // Fallback de segurança, embora o AuthWrapper deva nos proteger.
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não encontrado.")),
      );
    }

    final String initials = _user!.displayName?.isNotEmpty == true
        ? _user!.displayName![0].toUpperCase()
        : (_user!.email?.isNotEmpty == true ? _user!.email![0].toUpperCase() : '?');

    // Lemos o photoUrl do _user (que agora está no estado)
    final photoUrl = _user!.photoURL;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),

            // -- SEÇÃO DO AVATAR, NOME E E-MAIL --
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : (photoUrl == null
                          ? Text(initials, style: TextStyle(fontSize: 50, color: Colors.teal.shade800))
                          : null),
                ),
                Positioned(
                  bottom: 0,
                  right: MediaQuery.of(context).size.width / 2 - 80,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.teal),
                      onPressed: _pickAndUploadImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _user!.displayName ?? 'Usuário Anônimo',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _user!.email ?? 'E-mail não disponível',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // -- FIM DA SEÇÃO DO AVATAR --
            
            const Spacer(flex: 3),

            // -- BOTÃO "SOBRE" --
            TextButton.icon(
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              label: const Text('Sobre o app', style: TextStyle(color: Colors.grey)),
              onPressed: _showAboutDialog,
            ),
            const SizedBox(height: 10),

            // -- BOTÃO DE LOGOUT --
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 30),
              onPressed: () {
                _authService.signOut();
                if(mounted) {
                  // Ajuste: Garante que volte até a tela de login
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
            const Text('Sair', style: TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}