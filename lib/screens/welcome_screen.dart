import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_firebase_application/components/rounded_button.dart';
import 'package:chat_firebase_application/constants.dart';
import 'package:chat_firebase_application/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

//SingleTickerProviderStateMixin is used for enabling the _WelcomeScreenState to be used a Ticker.
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  //For Custom Animation.
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      //60 Tickers in one minutes = 60 frames in min; value increases from 0.0 to 1.0
      vsync:
          this, // can be used because the class is used with SingleTickerProviderStateMixin
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    controller.forward();

    animation.addStatusListener((status) {
      //This is used for looping in the animation.
      if (status == AnimationStatus.completed) {
        controller.reverse(from: 1.0);
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.addListener(() {
      setState(() {}); // using setState because to see the effect of animation.
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 45,
                  ),
                ),
                // Text(
                //   'Flash Chat',
                //   style: TextStyle(
                //       fontSize: 45,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: GoogleFonts.poppins().fontFamily),
                // ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      textStyle: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily),
                      speed: Duration(milliseconds: 500),
                    )
                  ],
                  totalRepeatCount: 4,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              btnTitle: "Log In",
              customFunction: () {
                Navigator.pushNamed(context, MyRoutes.loginRoute);
              },
              //Earlier it was a padding widget but as Login and Register button were same to optimize code we extracted
              //the padding widget and using only roundedButton widget.
            ),
            roundedButton(
                customFunction: () {
                  Navigator.pushNamed(context, MyRoutes.registerRoute);
                },
                btnTitle: "Register",
                color: Colors.lightBlueAccent.shade700)
          ],
        ),
      ),
    );
  }
}
