import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  Function({String text, File imgFile}) sendMessage;

  TextComposer(this.sendMessage, {Key? key}) : super(key: key);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _submitMessage(String text) {
    widget.sendMessage(text: text);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () async {
                var imgFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (imgFile == null) {
                  return;
                }
                widget.sendMessage(imgFile: File(imgFile.path));
              }),
          Expanded(
              child: TextField(
            decoration: const InputDecoration.collapsed(
                hintText: 'Enviar uma mensagem'),
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              _submitMessage(text);
            },
            controller: _controller,
          )),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    _submitMessage(_controller.text);
                  }
                : null,
          )
        ],
      ),
    );
  }
}
