import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddGamePage extends StatefulWidget {
  final String token;

  AddGamePage({required this.token});

  @override
  _AddGamePageState createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {

  final TextEditingController _universeNameController = TextEditingController();
  Map<String, dynamic>? selectedUniverse;
  List<Map<String, dynamic>> userUniverses = [];
  List<Map<String, dynamic>> charactersByUniverse = [];
  Map<String, dynamic>? selectedCharacters;
  bool isLoading = false;
  bool _isUniverseNameEmpty = true;
  bool isCharacterSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //définir les variables de couleur :
      backgroundColor: Color(0xFFF5F4F4),
      appBar: AppBar(
        title: const Text('ChatRP'),
        backgroundColor: Color(0xFFD9B998),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              SizedBox(height: 20),
              Card(
                color: Color(0xFF36453B),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Création d\'un jeu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _universeNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du jeu',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isUniverseNameEmpty = value.isEmpty;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isUniverseNameEmpty ? null : _createUniverse,
                        style: ElevatedButton.styleFrom(primary: Colors.orange),
                        child: const Text('Créer un jeu'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _createUniverse() async {
    final String universeName = _universeNameController.text;

    // Vérifier si le champ "Nom de l'univers" est vide
    if (universeName.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de saisie'),
          content: const Text('Veuillez saisir un nom pour le jeu.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Préparer les données pour la requête API
    final Map<String, String> requestData = {
      'nom': universeName,
    };

    // Convertir les données en JSON
    final String requestBody = jsonEncode(requestData);

    // Préparer les en-têtes de la requête
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': '${widget.token}',
    };


    // Faire l'appel à l'API "create universe"
    final url = Uri.parse('http://localhost:3000/games');
    final response = await http.post(
      url,
      headers: requestHeaders,
      body: requestBody,
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Jeu créé'),
          content: const Text('Le jeu a été créé avec succès.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de création API'),
          content: const Text(
              'Une erreur est survenue lors de la création du jeu.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    // Réinitialiser le champ de texte du nom de l'univers
    _universeNameController.clear();
  }
}
