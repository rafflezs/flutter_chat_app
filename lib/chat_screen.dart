import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'text_composer.dart';
import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late final User? _currentUser;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);

      final User? user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({text, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(content: Text("Não foi possível realizar o login")));
    }

    Map<String, dynamic> data = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderProfilePicture": user.photoURL,
      "timeStamp": Timestamp.now(),
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
      String urlImage = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = urlImage;
    }

    setState(() {
      _isLoading = false;
    });

    if (text != null) data["text"] = text;

    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_currentUser != null
            ? "Conversas de ${_currentUser!.displayName}"
            : "Conversas Banais"),
        backgroundColor: Colors.green[300],
        elevation: 0,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    // ignore: deprecated_memsber_use
                    _scaffoldKey.currentState?.showSnackBar(SnackBar(
                        content: Text("Conexão com usuário encerrada")));
                  },
                  icon: Icon(Icons.exit_to_app))
              : Container()
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .orderBy("timeStamp")
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                List<DocumentSnapshot> document =
                    snapshot.data!.docs.reversed.toList();

                return ListView.builder(
                  itemCount: document.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return ChatMessage(
                        document[index].data() as Map<String, dynamic>,
                        document[index].get("uid") == _currentUser?.uid);
                  },
                );
            }
          },
        )),
        _isLoading ? LinearProgressIndicator() : Container(),
        TextComposer(_sendMessage),
      ]),
    );
  }
}
