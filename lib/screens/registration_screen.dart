import 'package:flutter/material.dart';
import 'package:keep_chatting/constants.dart';
import 'package:keep_chatting/services/auth.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/widgets/widget_functions.dart';
import 'package:keep_chatting/widgets/round_button.dart';
import '../size_config.dart';
import 'forgetpassword.dart';

class RegistrationScreen extends StatefulWidget {
  final Function toggle;
  RegistrationScreen({this.toggle});
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool isLoading = false;
  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();
  String _error;

  /// Alert for incorrect input
  Widget showAlert() {
    if (_error != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.error_outline),
            SizedBox(
              width: 10,
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

  signMeUp() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await authMethods.signUpWithEmailAndPassword(
            context,
            userNameTextEditingController.text,
            emailTextEditingController.text,
            passwordTextEditingController.text);
      } catch (e) {
        setState(() {
          isLoading = false;
          _error = e.message;
          print(_error);
        });
      }
    }
  }

  signMeUpWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authMethods.signUpWithGoogle(context);
    } catch (e) {
      setState(() {
        _error = e.message;
        print(_error);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            showAlert(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 5.6 * SizeConfig.widthMultiplier,
                  vertical: 2.5 * SizeConfig.heightMultiplier),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 35.0 * SizeConfig.imageSizeMultiplier,
                    child: Image.asset('assets/images/chat.png'),
                  ),
                  SizedBox(
                    height: 6.25 * SizeConfig.heightMultiplier,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (userName) {
                            return (userName.isEmpty ||
                                    userName.length <= 2 ||
                                    userName.length >= 50)
                                ? 'Please provide a valid UserName'
                                : null;
                          },
                          controller: userNameTextEditingController,
                          textAlign: TextAlign.center,
                          style: kTextStyle,
                          decoration: kTextFieldDecoration.copyWith(
                            labelText: 'Name',
                            hintText: 'Enter Your UserName',
                          ),
                        ),
                        SizedBox(
                          height: 1 * SizeConfig.heightMultiplier,
                        ),
                        TextFormField(
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
                            labelText: 'Email',
                            hintText: 'Enter Your Email',
                          ),
                        ),
                        SizedBox(
                          height: 1 * SizeConfig.heightMultiplier,
                        ),
                        TextFormField(
                          validator: (password) {
                            return (password.length > 6)
                                ? null
                                : 'Please provide a password having 6+ characters';
                          },
                          controller: passwordTextEditingController,
                          textAlign: TextAlign.center,
                          obscuringCharacter: '*',
                          style: kTextStyle,
                          obscureText: true,
                          decoration: kTextFieldDecoration.copyWith(
                            labelText: 'Password',
                            hintText: 'Enter Password having 6+ characters',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 1 * SizeConfig.heightMultiplier,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPassword()));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.7 * SizeConfig.widthMultiplier,
                            vertical: 1 * SizeConfig.heightMultiplier),
                        child: Text(
                          'Forgot Password ?',
                          style: kTextStyle,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1 * SizeConfig.heightMultiplier,
                  ),
                  RoundButton(
                    text: 'Sign Up',
                    color: Colors.blue,
                    onPress: () {
                      signMeUp();
                    },
                    textColor: Colors.white,
                  ),
                  RoundButton(
                    text: 'Sign Up with Google',
                    color: Colors.white,
                    onPress: () {
                      signMeUpWithGoogle();
                    },
                    textColor: Colors.black,
                  ),
                  SizedBox(
                    height: 2 * SizeConfig.heightMultiplier,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account ? ",
                        style: kTextStyle,
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 1 * SizeConfig.heightMultiplier),
                          child: Text(
                            "Sign In Now !!",
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isLoading
                ? FittedBox(
                    child: Center(
                        child: Container(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    )),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
