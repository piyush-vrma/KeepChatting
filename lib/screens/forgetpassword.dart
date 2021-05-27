import 'package:flutter/material.dart';
import 'package:keep_chatting/constants.dart';
import 'package:keep_chatting/services/auth.dart';
import 'package:keep_chatting/widgets/widget_functions.dart';
import 'package:keep_chatting/widgets/round_button.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  AuthMethods authMethods = AuthMethods();
  TextEditingController emailTextEditingController = TextEditingController();
  String _error;
  bool isLoading = false;

  /// Alert for incorrect input
  Widget showAlert() {
    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.error_outline),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                _error,
                style: kTextStyle.copyWith(color: Colors.black),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                }),
          ],
        ),
      );
    }
    return SizedBox(
      height: 10,
    );
  }

  sendMail() async {
    if (_formKey.currentState.validate()) {
      var result;

      setState(() {
        isLoading = true;
      });

      try {
        result = await authMethods
            .resetPass(emailTextEditingController.text)
            .then((value) {
          print('check your mail');
          Navigator.pop(context, true);

          if (result != 0) {
            // Success
            _showAlertDialog('Link sent Successfully',
                'Please check your Mail and reset the password');
          } else {
            // Failure
            _showAlertDialog('Status', 'Problem while sending mail');
          }
        });
      } catch (e) {
        print('me error me hu');
        setState(() {
          isLoading = false;
          _error = e.message;
          print(_error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            showAlert(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'We will mail you a link . . . Please Click on that link to reset your Password !!',
                      style: kTextStyle.copyWith(
                          fontSize: 20, color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (email) {
                        return RegExp(
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                .hasMatch(email)
                            ? null
                            : 'Please provide a valid Email';
                      },
                      controller: emailTextEditingController,
                      textAlign: TextAlign.center,
                      style: kTextStyle,
                      keyboardType: TextInputType.emailAddress,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter Your Email',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  RoundButton(
                    text: 'Send Email',
                    color: Colors.blue,
                    onPress: () {
                      sendMail();
                    },
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
            isLoading
                ? Center(
                    child: Container(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ))
                : Container(),
          ],
        ),
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          // fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 24.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
