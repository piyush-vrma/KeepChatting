import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:keep_chatting/constants.dart';
import 'package:keep_chatting/helper/authenticate.dart';
import 'package:keep_chatting/helper/helper_functions.dart';
import 'package:keep_chatting/screens/chat_room_screen.dart';
import 'package:keep_chatting/size_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String token;
  bool isUserLoggedIn;
  bool isLoading = true;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  /// we are getting the loggedIn state of the user by this method from the shared Preference
  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isUserLoggedIn = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(
        builder: (context, orientation) {
          SizeConfig().init(constraints, orientation);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Keep CHATTING',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(0xFF0A0E21),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: isLoading == false
                ? isUserLoggedIn != null
                    ? (isUserLoggedIn ? ChatRoom() : Authenticate())
                    : Authenticate()
                : Scaffold(
                    body: Container(
                      color: Color(0xFF0A0E21),
                      child: Center(
                        child: Text(
                          'Loading...',
                          style: kTextStyle.copyWith(
                              fontSize: 40.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
          );
        },
      );
    });
  }
}
