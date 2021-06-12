import 'package:chat_firebase_application/components/rounded_button.dart';
import 'package:chat_firebase_application/constants.dart';
import 'package:chat_firebase_application/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (mailVal) {
                    email = mailVal;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      //All the decorations has been stored in a const
                      hintText: "Enter Your Email")),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (passVal) {
                    password = passVal;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter Your Password")),
              SizedBox(
                height: 20.0,
              ),
              roundedButton(
                color: Colors.lightBlueAccent,
                btnTitle: "Log In",
                customFunction: () async {
                  try {
                    setState(() {
                      showSpinner = true;
                    });
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      setState(() {
                        showSpinner = false;
                      });
                      FocusManager.instance.primaryFocus.unfocus();
                      Fluttertoast.showToast(
                          msg: "Logged In Successfully with $email.",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.lightGreen);
                      Navigator.pushNamed(context, MyRoutes.chatRoute);
                    }
                  } catch (ERROR_USER_NOT_FOUND) {
                    setState(() {
                      showSpinner = false;
                    });
                    Fluttertoast.showToast(
                        msg: "Email or password is wrong.",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
