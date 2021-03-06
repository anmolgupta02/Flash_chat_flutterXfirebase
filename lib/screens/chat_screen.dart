import 'package:chat_firebase_application/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;

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
        title: Text('??? Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MsgStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextEditingController,
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
                      //This is used for clearing the text on the text field.
                      messageTextEditingController.clear();
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

// For modular code we separated the code from the above class.
class MsgStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      /*This is for getting the source of data. In our case it is Stream which is sent by
                firebase through _firestore*/
      stream: _firestore.collection('messages').snapshots(),
      /*this asyncSnapshot is property of flutter through which is it connecting the
                  firebase stream and the widget builder stream*/
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          //the connection of Flutter Stream and Firebase Stream and the data is hold in messages.
          //adding .reversed because we added ListView property as True, which helped
          //us in solving the issue of new message going out of view window
          //But if we send message it was getting to the top. So we are revering the snapshot and then reversing the list altogether.
          final messages = asyncSnapshot.data.documents.reversed;
          //Because we want to show the messages as a column containing list of data.
          List<MessageBubble> msgWidget = [];
          //Looping through the objects we got from firebase.
          for (var messages in messages) {
            //In firebase to access the msg we need to have collections -> snapshot -> Document -> data -> Property
            final msgText = messages.data["text"];
            final messageSender = messages.data["sender"];
            //Creating Single Text Widgets from each objects
            final currentUser = loggedInUser.email;
            //To check if the current user is the sender of the message

            final singleMsgWidget = MessageBubble(
              sender: messageSender,
              text: msgText,
              isMe: currentUser == messageSender,
            );
            //Adding this singleMsgWidget to the list.
            msgWidget.add(singleMsgWidget);
          }
          //Using listView becuase we want to use scrolling effect.
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              //Finally showing List of Text widget to the Column.
              children: msgWidget,
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
      },
    );
  }
}

//Designing the message body. To shape it like a bubble.
class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender, text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Material(
            borderRadius: BorderRadius.only(
                topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: isMe ? Radius.circular(0) : Radius.circular(30)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
