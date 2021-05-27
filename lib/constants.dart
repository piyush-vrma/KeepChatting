import 'package:flutter/material.dart';

class Constants {
  static String myName = "";
  static String myEmail = "";
  // static String conversationUserPic = "";
  // static String conversationUserName = "";
}

const kTextStyle = TextStyle(color: Colors.white);

const kHintTextStyle = TextStyle(color: Colors.white54);

const kIconsColor = Colors.white;

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  labelStyle: TextStyle(
    color: Colors.blue,
  ),
  hintStyle: TextStyle(color: Colors.white54),
);

// Just like out line input boarder we are having underline input border

const kAccountFieldTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 1.0),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
  ),
  labelStyle: TextStyle(
    color: Colors.blue,
  ),
  hintStyle: TextStyle(color: Colors.white54),
);
