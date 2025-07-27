// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final imageFile = File(pickedFile.path);
      await _authService.uploadProfilePicture(imageFile);
      
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;

        final String initials = user?.displayName?.isNotEmpty == true
            ? user!.displayName![0].toUpperCase()
            : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?');

        final photoUrl = user?.photoURL;

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
              crossAxisAlignment: CrossAxisAlignment.stretch, // Centraliza horizontalmente
              children: [
                // Adiciona espaço flexível no topo para empurrar o conteúdo para o centro
                const Spacer(flex: 2),

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
                      right: MediaQuery.of(context).size.width / 2 - 80, // Centraliza o ícone de edição
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
                  user?.displayName ?? 'Usuário Anônimo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'E-mail não disponível',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                
                // Adiciona espaço flexível abaixo para empurrar o botão para o final
                const Spacer(flex: 3), 

                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 30),
                  onPressed: () {
                    _authService.signOut();
                    if(mounted) {
                      Navigator.of(context).pop();
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
    );
  }
}