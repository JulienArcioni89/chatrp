import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConversationPage extends StatefulWidget {
  final String token;
  final int conversationId;

  ConversationPage({required this.token, required this.conversationId});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    String message = _messageController.text;
    _messageController.clear();

    setState(() {
      _isTyping = true; // Activer l'indicateur de saisie
    });

    final Map<String, dynamic> requestData = {'message': message};

    final String requestBody = jsonEncode(requestData);

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': '${widget.token}',
    };

    final url =
        Uri.parse('http://localhost:3000/chat/${widget.conversationId}');

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: requestBody,
    );
    // print('Contenu du body envoyé : ${requestBody}');
    // print('Contenu de la reponse : ${response.body}');

    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(response.body);

      String receivedMessage = responseData['response'];
      String sentMessage = requestData['message'];

      setState(() {
        _messages.add({'message': sentMessage, 'is_sent_by_human': true});
        _messages.add({'message': receivedMessage, 'is_sent_by_human': false});
      });
    }
    // Après avoir envoyé le message, désactivez l'indicateur de saisie
    setState(() {
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F4F4),
      appBar: AppBar(
        title: const Text('Conversation'),
        backgroundColor: Color(0xFFD9B998),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                if (_messages.isEmpty) {
                  return Container(); // Return an empty container if the list is empty
                }

                Map<String, dynamic> message =
                    _messages[_messages.length - index - 1];
                bool isSentByHuman = message.containsKey('is_sent_by_human')
                    ? message['is_sent_by_human']
                    : false;

                return Row(
                  mainAxisAlignment: isSentByHuman
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      // Limit the width of the bubble
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSentByHuman
                            ? Color(0xFFE66745)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message['message'],
                        style: TextStyle(
                          color: isSentByHuman ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
