import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mydigitalgpt/conversation.dart';
import 'package:mydigitalgpt/addGame.dart';
import 'package:mydigitalgpt/addCharacter.dart';
import 'package:mydigitalgpt/startConversation.dart';

class HomePage extends StatefulWidget {
  final String token;

  HomePage({required this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    _characterNameController.addListener(_updateCharacterNameEmptyState);
    _fetchUserUniverses();
  }

  @override
  void dispose() {
    _characterNameController.removeListener(_updateCharacterNameEmptyState);
    _characterNameController.dispose();
    super.dispose();
  }

  void _updateCharacterNameEmptyState() {
    setState(() {
      _isCharacterNameEmpty = _characterNameController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.token;
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    final username = decodedToken['username'];

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

              Center(
                child: Text(
                  'Bonjour $username !',
                  style: TextStyle(fontSize: 28, color: Color(0xFF36453B)),
                ),
              ),
              SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGamePage(token: '$token',)),
                  );
                },
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.gamepad, // Icône de manette de jeu
                          size: 50,
                          color: Colors.black,
                        ),
                        Text(
                          'Ajouter un jeu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCharacterPage(token: '$token',)),
                  );
                },
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add, // Icône de manette de jeu
                          size: 50,
                          color: Colors.black,
                        ),
                        Text(
                          'Ajouter un personnage',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StartConversationPage(token: '$token',)),
                  );
                },
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          size: 50,
                          color: Colors.black,
                        ),
                        Text(
                          'Commencer une conversation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


/*              Card(
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
              SizedBox(height: 20),*/
/*              Card(
                color: Color(0xFF36453B),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Ajout d\'un personnage',
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
                      DropdownButton<Map<String, dynamic>>(
                        value: selectedUniverse,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedUniverse = newValue;
                          });
                        },
                        items: userUniverses.map<DropdownMenuItem<Map<String, dynamic>>>(
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
                      TextField(
                        controller: _characterNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du personnage',
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isCharacterNameEmpty ? null : _createCharacter,
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        child: const Text('Créer un personnage'),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading) CircularProgressIndicator(),*/
              SizedBox(height: 20),
              Card(
                color: Color(0xFF36453B),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Sélection d\'un personnage',
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
                        items: userUniverses.map<DropdownMenuItem<Map<String, dynamic>>>(
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
                        items: charactersByUniverse.map<DropdownMenuItem<Map<String, dynamic>>>(
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
                        style: ElevatedButton.styleFrom(primary: Colors.purple),
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

  Future<void> _startConversation() async {
    if (selectedUniverse != null && selectedCharacters != null) {
      print('Jeu sélectionné : ${selectedUniverse!['id']}');
      print('Personnage sélectionné : ${selectedCharacters!['id']}');

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      final user_id = decodedToken['id'];

      // Préparer les données pour la requête API
      final Map<String, dynamic> requestData = {
        'character_id': selectedCharacters!['id'],
        'user_id': user_id,
      };

      // Convertir les données en JSON
      final String requestBody = jsonEncode(requestData);

      // Préparer les en-têtes de la requête
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': '${widget.token}',
      };

      final url = Uri.parse('http://localhost:3000/chat/${selectedCharacters!['id']}');


      // Faire l'appel à l'API "create character"
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      // Traiter la réponse de l'API
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final conversationId = responseData['id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              token: widget.token,
              conversationId: conversationId,
            ),
          ),
        );
      } else {
        print(response.body);
        print(response.statusCode);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur de création API'),
            content: const Text(
                'Une erreur est survenue lors de la création de la conversation.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } else {
      print('Veuillez sélectionner un jeu et un personnage.');
    }
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

    final url = Uri.parse('http://localhost:3000/games');

    // Faire l'appel à l'API "create universe"
    final response = await http.post(
      url,
      headers: requestHeaders,
      body: requestBody,
    );

    if (response.statusCode == 201) {
/*      final responseData = jsonDecode(response.body);
      final errorMessage = responseData['message'];
      print(errorMessage);*/
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

    // Rafraîchir la liste des univers de l'utilisateur
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
      final List<Map<String, dynamic>> universes =
          universesData.map<Map<String, dynamic>>((data) {
        final int id = data['id'] as int;
        final String name = data['nom'] as String;
        return {'id': id, 'nom': name};
      }).toList();
      setState(() {
        userUniverses = universes;
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
  }
}