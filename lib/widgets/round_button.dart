import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  RoundButton({this.textColor, this.color, this.text, @required this.onPress});

  final Color color;
  final String text;
  final textColor;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(32.0),
        child: MaterialButton(
          onPressed: onPress,
          // minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
