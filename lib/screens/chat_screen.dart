import 'package:chat_firebase_application/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String chat;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      try {
        loggedInUser = user;
        print(loggedInUser.email);
      } catch (e) {
        print(e);
      }
    }
  }

  // By using getMessage(), we have to call the change manually each time no instant check can be there.

  // void getMessage() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var messages in messages.documents) {
  //     print(messages.data);
  //   }
  // }

  //By Using Stream we can get instant messages as it listens to change in the collections.
  //snapshot gives a Stream of QuerySnapshot which helps us getting new messages instantly.
  void messageStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var msg in snapshot.documents) {
        print(msg.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //List<Text> msgWidget = [];
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                //getMessage();
                messageStream();
                Fluttertoast.showToast(
                    msg: "User Signed Out successfully.",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.green);

                Navigator.pop(context);
              }),
        ],
        title: Text('⚡ Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              /*This is for getting the source of data. In our case it is Stream which is sent by
                firebase through _firestore*/
              builder: (context, asyncSnapshot) {
                /*this asyncSnapshot is property of flutter through which is it connecting the
                  firebase stream and the widget builder stream*/
                if (asyncSnapshot.hasData) {
                  //the connection of Flutter Stream and Firebase Stream and the data is hold in messages.
                  final messages = asyncSnapshot.data.documents;
                  //Because we want to show the messages as a column containing list of data.
                  List<Text> msgWidget = [];
                  //Looping through the objects we got from firebase.
                  for (var messages in messages) {
                    //In firrbase to access the msg we need to have collections -> snapshot -> Document -> data -> Property
                    final msgText = messages.data["text"];
                    final messageSender = messages.data["sender"];
                    //Creating Single Text Widgets from each objects
                    final singleMsgWidget =
                        Text('$msgText from $messageSender');
                    //Adding this singleMsgWidget to the list.
                    msgWidget.add(singleMsgWidget);
                  }
                  return Column(
                    children: msgWidget,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        chat = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                          hintText: "Type a message to send.."),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'text': chat,
                        'sender': loggedInUser.email,
                      });
                      FocusManager.instance.primaryFocus.unfocus();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
