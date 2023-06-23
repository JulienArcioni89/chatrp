import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCharacterPage extends StatefulWidget {
  final String token;

  AddCharacterPage({required this.token});

  @override
  _AddCharacterPageState createState() => _AddCharacterPageState();
}

class _AddCharacterPageState extends State<AddCharacterPage> {
  final TextEditingController _characterNameController =
  TextEditingController();
  final TextEditingController _universeNameController = TextEditingController();
  Map<String, dynamic>? selectedUniverse;
  List<Map<String, dynamic>> userUniverses = [];
  List<Map<String, dynamic>> charactersByUniverse = [];
  Map<String, dynamic>? selectedCharacters;
  bool isLoading = false;
  bool _isCharacterNameEmpty = true;
  bool _isUniverseNameEmpty = true;
  bool isCharacterSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchUserUniverses();
  }

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
                    'Ajout d\'un personnage',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                      DropdownButton<Map<String, dynamic>>(
                        value: selectedUniverse,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedUniverse = newValue;
                          });
                        },
                        items: userUniverses
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (Map<String, dynamic> value) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: value,
                              child: Text(value['nom']),
                            );
                          },
                        ).toList(),
                        hint: Text('Sélectionner un jeu'),
                        // disabledHint: Text('Aucun jeu disponible'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _characterNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du personnage',
                        ),
                        onChanged: _onCharacterNameChanged, // Ajouter cette ligne
                      ),

                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:
                            _isCharacterNameEmpty ? null : _createCharacter,
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        child: const Text('Créer un personnage'),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _createCharacter() async {
    final String characterName = _characterNameController.text;

    // Mettre à jour l'état de _isCharacterNameEmpty
    setState(() {
      _isCharacterNameEmpty = characterName.isEmpty;
    });

    // Vérifier si le champ "Nom du personnage" est vide
    if (_isCharacterNameEmpty) {
      return;
    }

    // Vérifier si un univers a été sélectionné
    if (selectedUniverse == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de sélection'),
          content: const Text('Veuillez sélectionner un jeu.'),
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

    setState(() {
      isLoading = true;
    });

    // Préparer les données pour la requête API
    final Map<String, dynamic> requestData = {
      'nom': characterName,
      'universe': selectedUniverse,
    };

    // Convertir les données en JSON
    final String requestBody = jsonEncode(requestData);

    // Préparer les en-têtes de la requête
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': '${widget.token}',
    };

    final url = Uri.parse(
        'http://localhost:3000/characters/game/${selectedUniverse!['id']}');

    // Faire l'appel à l'API "create character"
    final response = await http.post(
      url,
      headers: requestHeaders,
      body: requestBody,
    );

    // Traiter la réponse de l'API
    if (response.statusCode == 201) {
      // Récupérer l'ID du personnage créé
      setState(() {
        isLoading = false;
      });
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final url = Uri.parse(
          'http://localhost:3000/characters/game/${selectedUniverse!['id']}/characters/${responseData['id']}');
      final generateDescription = await http.put(
        url,
        headers: requestHeaders,
      );

      // Succès : personnage créé avec succès
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Personnage créé'),
          content: const Text('Le personnage a été créé avec succès.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  isLoading = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      // Erreur : échec de la création du personnage
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de création'),
          content: const Text(
              'Une erreur est survenue lors de la création du personnage.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  isLoading = false; // Désactiver le chargement
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Réinitialiser le champ de texte du nom du personnage
    _characterNameController.clear();
    _fetchUserUniverses();
  }
  void _fetchUserUniverses() async {
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': '${widget.token}',
    };

    final url = Uri.parse('http://localhost:3000/games');

    final response = await http.get(
      url,
      headers: requestHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> universesData = jsonDecode(response.body);
      final Set<Map<String, dynamic>> distinctUniverses = {};

      universesData.forEach((data) {
        final int id = data['id'] as int;
        final String name = data['nom'] as String;
        distinctUniverses.add({'id': id, 'nom': name});
      });

      final List<Map<String, dynamic>> universes = distinctUniverses.toList();

      setState(() {
        userUniverses = universes;
        selectedUniverse = universes.isNotEmpty ? universes[0] : null;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de récupération des jeux'),
          content: const Text(
              'Une erreur est survenue lors de la récupération des jeux.'),
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
  void _onCharacterNameChanged(String value) {
    setState(() {
      _isCharacterNameEmpty = value.isEmpty;
    });
  }


}
