import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.color, this.customFunction, this.btnTitle});
  final Color color;
  final Function customFunction;
  final String btnTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        clipBehavior: Clip.antiAlias,
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: customFunction,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            btnTitle,
            style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
          ),
        ),
      ),
    );
  }
}

Padding roundedButton(
    {@required Color color,
    @required String btnTitle,
    @required customFunction()}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Material(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: () {
          customFunction();
        },
        minWidth: 200.0,
        height: 42.0,
        child: Text(
          btnTitle,
          style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
        ),
      ),
    ),
  );
}
