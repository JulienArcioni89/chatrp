import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mydigitalgpt/conversation.dart';

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
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    final mail = decodedToken['mail'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Espace'),
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Bonjour, $mail !',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Création d\'un univers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _universeNameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'univers',
            ),
            onChanged: (value) {
              setState(() {
                _isUniverseNameEmpty = value.isEmpty;
              });
            },
          ),
          ElevatedButton(
            onPressed: _isUniverseNameEmpty ? null : _createUniverse,
            child: const Text('Créer un univers'), // Texte du bouton
          ),
          SizedBox(height: 20),
          Text(
            'Ajout d\'un personnage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            }).toList(),
            hint: Text('Sélectionner un univers'),
          ),
          TextField(
            controller: _characterNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du personnage',
            ),
          ),
          ElevatedButton(
            onPressed: _isCharacterNameEmpty ? null : _createCharacter,
            child: const Text('Créer un personnage'),
          ),
          if (isLoading) CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Sélection d\'un personnage',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
            }).toList(),
            hint: Text('Sélectionner un univers'),
          ),
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
            }).toList(),
            hint: Text('Sélectionner un personnage'),
          ),
          ElevatedButton(
            onPressed: isCharacterSelected ? _startConversation : null,
            child: const Text('Démarrer la conversation'),
          ),
        ],
      ),
    );
  }

  Future<void> _startConversation() async {
    if (selectedUniverse != null && selectedCharacters != null) {
      print('Univers sélectionné : ${selectedUniverse!['id']}');
      print('Personnage sélectionné : ${selectedCharacters!['id']}');

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      print(decodedToken);
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
      print('Veuillez sélectionner un univers et un personnage.');
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
          content: const Text('Veuillez saisir un nom pour l\'univers.'),
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
          title: const Text('Univers créé'),
          content: const Text('L\'univers a été créé avec succès.'),
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
              'Une erreur est survenue lors de la création de l\'univers.'),
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
          title: const Text('Erreur de récupération des univers'),
          content: const Text(
              'Une erreur est survenue lors de la récupération des univers.'),
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
          content: const Text('Veuillez sélectionner un univers.'),
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