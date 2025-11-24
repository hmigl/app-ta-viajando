import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/core/services/auth_provider.dart';

class RegisterView extends ConsumerWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _nameController = TextEditingController(); 
  
    return Scaffold( 
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            
            

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                try {
                  if (_emailController.text.isEmpty || 
                      _passwordController.text.isEmpty || 
                      _nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, preencha todos os campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                    _nameController.text, 
                  );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conta criada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  Navigator.pop(context); 
                }
                
              } catch (error) {
                if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao criar conta: ${error.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sign in'),
            ),
           
          ],
        ),
      ),
    );
  }
}