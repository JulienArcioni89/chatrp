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
  bool _isUsernameFocused = false;
  bool _isPasswordFocused = false;
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();


  String? _token;

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;


    // Création du corps de la requête en utilisant les données d'authentification
    final String body = json.encode({
      'mail': username,
      'pwd': password,
    });

    final url = Uri.parse('http://localhost:3000/users/login');

    // Envoi de la requête POST pour obtenir le token
    final response = await http.post(
      headers: {'Content-Type': 'application/json'},
      url,
      body: body,
    );

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
                );
              },
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
        title: const Text("Connexion"),
        centerTitle: true,
        backgroundColor: Color(0xFFD9B998),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 40.0),
                child: Image.asset('assets/logo_conv.png'),
              ),
              const SizedBox(height: 16.0),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isUsernameFocused ? Color(0xFFD9B998) : Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: _isUsernameFocused ? Colors.black : Colors.black,
                    ),
                    contentPadding: EdgeInsets.only(left: 8.0),
                  ),
                  onTap: () {
                    setState(() {
                      _isUsernameFocused = true;
                      _isPasswordFocused = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isPasswordFocused ? Color(0xFFD9B998) : Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: _isUsernameFocused ? Colors.black : Colors.black,
                    ),
                    contentPadding: EdgeInsets.only(left: 8.0),
                  ),
                  onTap: () {
                    setState(() {
                      _isUsernameFocused = false;
                      _isPasswordFocused = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFE66745),
                  onPrimary: Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                ),
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 14, color: Color(0xFF36453B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
