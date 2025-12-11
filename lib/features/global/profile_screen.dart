import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ta_viajando_app/features/auth/data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _currentAvatarUrl;
  Uint8List? _newAvatarBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getMyProfile();
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      setState(() {
        _currentAvatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } catch (e) {
      // Tratar erro
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _newAvatarBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      String? newUrl;
      // 1. Upload da foto se mudou
      if (_newAvatarBytes != null) {
        newUrl = await ref.read(profileRepositoryProvider).uploadAvatar(_newAvatarBytes!);
      }

      // 2. Atualizar perfil
      await ref.read(profileRepositoryProvider).updateProfile(
        name: _nameController.text,
        avatarUrl: newUrl ?? _currentAvatarUrl,
        newEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
        newPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
        if (_emailController.text.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifique seu email para confirmar a troca.')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _newAvatarBytes != null
                    ? MemoryImage(_newAvatarBytes!)
                    : (_currentAvatarUrl != null ? NetworkImage(_currentAvatarUrl!) : null) as ImageProvider?,
                child: (_newAvatarBytes == null && _currentAvatarUrl == null)
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            TextButton(onPressed: _pickImage, child: const Text('Alterar Foto')),
            
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Novo Email (Opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(labelText: 'Nova Senha (Opcional)', border: OutlineInputBorder()),
              obscureText: true,
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _save, child: const Text('Salvar Alterações')),
            ),
          ],
        ),
      ),
    );
  }
}