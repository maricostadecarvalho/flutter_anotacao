import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;

  Future<void> entrar() async {
    if (usuarioController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha usuário e senha"),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final resposta = await http.post(
        Uri.parse("https://dummyjson.com/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": usuarioController.text.trim(),
          "password": senhaController.text.trim(),
          "expiresInMins": 30,
        }),
      );

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        String token = dados["accessToken"];

        print(token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else {
        final dados = jsonDecode(resposta.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              dados["message"] ?? "Usuário ou senha incorretos",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao conectar com a API"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(
                labelText: "Usuário",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : entrar,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text("Entrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}

