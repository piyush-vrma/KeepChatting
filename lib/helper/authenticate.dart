import 'package:flutter/material.dart';
import 'package:keep_chatting/screens/login_screen.dart';
import 'package:keep_chatting/screens/registration_screen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginScreen(
        toggle: toggleView,
      );
    } else {
      return RegistrationScreen(
        toggle: toggleView,
      );
    }
  }
}
