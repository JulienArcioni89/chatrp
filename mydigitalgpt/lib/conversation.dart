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


    final Map<String, dynamic> requestData = {
      'content': message
    };

    final String requestBody = jsonEncode(requestData);

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.post(
      Uri.https('caen0001.mds-caen.yt', '/conversations/${widget.conversationId}/messages'),
      headers: requestHeaders,
      body: requestBody,
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> sentMessage = responseData['message'];
      Map<String, dynamic> receivedMessage = responseData['answer'];

      setState(() {
        _messages.add(sentMessage);
        _messages.add(receivedMessage);
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
      appBar: AppBar(
        title: Text('Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> message = _messages[_messages.length - index - 1];
                bool isSentByHuman = message['is_sent_by_human'];

                return Align(
                  alignment: isSentByHuman ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isSentByHuman ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message['content'],
                      style: TextStyle(
                        color: isSentByHuman ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
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
                        borderRadius: BorderRadius.circular(24.0),
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
