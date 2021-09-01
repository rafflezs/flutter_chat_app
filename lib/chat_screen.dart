import 'package:flutter/material.dart';
import 'text_composer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teste"),
        backgroundColor: Colors.green[300],
        elevation: 0,
      ),
      body: TextComposer(),
    );
  }
}
