import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  bool _isFirstNameFocused = false;
  bool _isLastNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  Future<void> _register() async {
    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String firstname = _firstnameController.text;
    final String lastname = _lastnameController.text;

    final String body = json.encode({
      // 'username': username,
      'pwd': password,
      'mail': email,
      'nom': firstname,
      'prenom': lastname,
    });

    final url = Uri.parse('http://localhost:3000/users');

    final response = await http.post(
      headers: {'Content-Type': 'application/json'},
      url,
      body: body,
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Succès'),
          content: const Text('Bravo ! Votre Compte a été créé avec succès !'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Une erreur s\'est produite. Veuillez vérifier votre saisie et réessayer.'),
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
        title: const Text("Créer mon Compte"),
        backgroundColor: Color(0xFFD9B998),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstnameController,
              decoration: InputDecoration(
                labelText: 'Prénom',
                labelStyle: TextStyle(color: _isFirstNameFocused ? Colors.black : Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9B998), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.only(left: 8.0),
              ),
              onTap: () {
                setState(() {
                  _isFirstNameFocused = true;
                  _isLastNameFocused = false;
                  _isEmailFocused = false;
                  _isPasswordFocused = false;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _lastnameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(color: _isLastNameFocused ? Colors.black : Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9B998), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.only(left: 8.0),
              ),
              onTap: () {
                setState(() {
                  _isFirstNameFocused = false;
                  _isLastNameFocused = true;
                  _isEmailFocused = false;
                  _isPasswordFocused = false;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: _isEmailFocused ? Colors.black : Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9B998), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.only(left: 8.0),
              ),
              onTap: () {
                setState(() {
                  _isFirstNameFocused = false;
                  _isLastNameFocused = false;
                  _isEmailFocused = true;
                  _isPasswordFocused = false;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de Passe',
                labelStyle: TextStyle(color: _isPasswordFocused ? Colors.black : Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9B998), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.only(left: 8.0),
              ),
              onTap: () {
                setState(() {
                  _isFirstNameFocused = false;
                  _isLastNameFocused = false;
                  _isEmailFocused = false;
                  _isPasswordFocused = true;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFE66745),
                onPrimary: Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
              child: const Text('J\'active mon compte',
                style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }}