import 'package:chat_firebase_application/routes.dart';
import 'package:chat_firebase_application/screens/chat_screen.dart';
import 'package:chat_firebase_application/screens/login_screen.dart';
import 'package:chat_firebase_application/screens/register_screen.dart';
import 'package:chat_firebase_application/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(
              color: Colors.black54, fontFamily: GoogleFonts.lato().fontFamily),
        ),
      ),
      initialRoute: MyRoutes.homeRoute,
      routes: {
        MyRoutes.homeRoute: (context) => WelcomeScreen(),
        MyRoutes.loginRoute: (context) => LoginScreen(),
        MyRoutes.registerRoute: (context) => RegisterScreen(),
        MyRoutes.chatRoute: (context) => ChatScreen(),
      },
    );
  }
}
