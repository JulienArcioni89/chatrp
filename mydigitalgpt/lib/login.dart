import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mydigitalgpt/homePage.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _token;

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // print('username : $username');
    // print('password : $password');

    // Création du corps de la requête en utilisant les données d'authentification
    final String body = json.encode({
      'mail': username,
      'pwd': password,
    });
    print('body : $body');
    final url = Uri.parse('http://localhost:3000/users/login');

    // Envoi de la requête POST pour obtenir le token
    final response = await http.post(
      headers: {'Content-Type': 'application/json'},
      url,
      body: body,
    );

    // print('Code de statut : ${response.statusCode}');
    // print('Corps de la réponse : ${response.body}');


    if (response.statusCode == 200) {
      // Analyse de la réponse JSON pour extraire le token
      final data = json.decode(response.body);
      final token = data['token'];

      // Stockage du token pour une utilisation ultérieure
      setState(() {
        _token = token;
      });

      // Gestion du succès
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Félicitations !'),
          content: const Text('Identifiants corrects. Vous êtes connecté'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(token: token),
                  ),
                );              },
            ),
          ],
        ),
      );
      // Navigation vers la page "Mon espace" avec le nom d'utilisateur
    } else {
      // Gestion des erreurs de connexion
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de connexion'),
          content: const Text('Identifiants invalides. Veuillez réessayer.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page de Connexion"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  )),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de Passe',
                ),
              ),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Se connecter'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Créer un compte'))
            ],
          )),
    );
  }
}