import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:chatrp/conversation.dart';
import 'package:chatrp/addGame.dart';
import 'package:chatrp/addCharacter.dart';
import 'package:chatrp/startConversation.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        title: const Text('Tableau de bord'),
        backgroundColor: Color(0xFFD9B998),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Text(
                    'Bonjour $username !',
                    style: TextStyle(fontSize: 28, color: Color(0xFF36453B)),
                  ),
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
                  margin: EdgeInsets.only(top: 60.0, bottom: 30.0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFFD9B998), width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: SvgPicture.asset(
                            'assets/game.svg',
                            height: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: Text(
                            'Ajouter un jeu',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
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
                  margin: EdgeInsets.only(bottom: 30.0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFFD9B998), width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: SvgPicture.asset(
                            'assets/person.svg',
                            height: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: Text(
                            'Ajouter un personnage',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
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
                  margin: EdgeInsets.only(bottom: 30.0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFFD9B998), width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: SvgPicture.asset(
                            'assets/chat.svg',
                            height: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(6.0),
                          child: Text(
                            'Commencer une conversation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
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