import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mydigitalgpt/conversation.dart';


class StartConversationPage extends StatefulWidget {
  final String token;

  StartConversationPage({required this.token});

  @override
  _StartConversationPageState createState() => _StartConversationPageState();
}

class _StartConversationPageState extends State<StartConversationPage> {
  Map<String, dynamic>? selectedUniverse;
  List<Map<String, dynamic>> userUniverses = [];
  List<Map<String, dynamic>> charactersByUniverse = [];
  Map<String, dynamic>? selectedCharacters;
  bool isLoading = false;
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
                    'Sélection d\'un personnage',
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
                            if (newValue != null) {
                              _fetchCharactersByUniverse(newValue['id']);
                            }
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
                      ),
                      SizedBox(height: 10),
                      DropdownButton<Map<String, dynamic>>(
                        value: selectedCharacters,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedCharacters = newValue;
                            isCharacterSelected = newValue != null;
                          });
                        },
                        items: charactersByUniverse
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (Map<String, dynamic> value) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: value,
                              child: Text(value['name']),
                            );
                          },
                        ).toList(),
                        hint: Text('Sélectionner un personnage'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: isCharacterSelected
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationPage(
                                      token: widget.token,
                                      conversationId: selectedCharacters!['id'],
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFE66745),
                          onPrimary: Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        child: const Text('Démarrer la conversation'),

                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  void _fetchCharactersByUniverse(int GameId) async {
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': '${widget.token}',
    };

    final url = Uri.parse('http://localhost:3000/characters/game/$GameId');

    final response = await http.get(
      url,
      headers: requestHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> charactersData = jsonDecode(response.body);
      final List<Map<String, dynamic>> characters =
      charactersData.map<Map<String, dynamic>>((data) {
        final int id = data['id'] as int;
        final String name = data['name'] as String;
        return {'name': name, 'id': id};
      }).toList();

      setState(() {
        charactersByUniverse = characters;
      });
    }
  }
}
