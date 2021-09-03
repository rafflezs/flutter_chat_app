import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(this.data, this.isMe);

  final Map<String, dynamic> data;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: <Widget>[
          !isMe
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderProfilePicture']),
                  ),
                )
              : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              data['imgUrl'] != null
                  ? Image.network(
                      data["imgUrl"],
                      width: 250,
                    )
                  : Text(
                      data["text"],
                      style: TextStyle(fontSize: 17),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
              Text(
                data['senderName'],
                style: TextStyle(fontSize: 13),
              ),
            ],
          )),
          isMe
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderProfilePicture']),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
