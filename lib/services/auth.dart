import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keep_chatting/helper/authenticate.dart';
import 'package:keep_chatting/helper/helper_functions.dart';
import 'package:keep_chatting/models/logged_in_user.dart';
import 'package:keep_chatting/screens/chat_room_screen.dart';
import 'database.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  DatabaseMethods databaseMethods = DatabaseMethods();
  LoggedInUser loggedInUser = LoggedInUser();

  ///  Functions . . . . . . .

  /// SignIN Function
  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    final oldUser = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User firebaseUser = oldUser.user;

    /// Sign success
    if (firebaseUser != null) {
      QuerySnapshot resultQuery = await databaseMethods.getUserUserEmail(email);
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      /// old user thereFore we only store data to the sharedPreference
      /// write data to local sharedPreference

      HelperFunctions.saveUserNameSharedPreference(
          documentSnapshots[0].data()["name"]);
      HelperFunctions.saveUserEmailSharedPreference(
          documentSnapshots[0].data()["email"]);
      HelperFunctions.saveUserPhotoUrlSharedPreference(
          documentSnapshots[0].data()["photoUrl"]);
      HelperFunctions.saveUserAboutMeSharedPreference(
          documentSnapshots[0].data()["aboutMe"]);
      HelperFunctions.saveUserLoggedInSharedPreference(true);

      Fluttertoast.showToast(
        msg: "Congratulations, LogIn Successful",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatRoom()),
      );
    } else {
      /// SignIn Failed
      Fluttertoast.showToast(
        msg: "Try Again, LogIn Failed.",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );
    }
  }

  /// signUp Function
  Future<void> signUpWithEmailAndPassword(BuildContext context, String userName,
      String email, String password) async {
    final newUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User firebaseUser = newUser.user;

    /// SignUp Success
    if (firebaseUser != null) {
      /// if  new user, then Save Data to fireStore;
      ///  FireStore store the data in the form of map therefore we store the firebaseUser data as a map object which is defined in the loggedIN user class

      Map<String, dynamic> userMap =
          loggedInUser.toMap(firebaseUser, userName: userName);

      /// uploading data to the fireStore
      await databaseMethods.uploadUserInfo(firebaseUser.uid, userMap);

      /// write data to local sharedPreference
      HelperFunctions.saveUserNameSharedPreference(userName);
      HelperFunctions.saveUserEmailSharedPreference(email);
      HelperFunctions.saveUserPhotoUrlSharedPreference("");
      HelperFunctions.saveUserAboutMeSharedPreference('I Love KeepCHATTING');
      HelperFunctions.saveUserLoggedInSharedPreference(true);

      Fluttertoast.showToast(
        msg: "Congratulations, SignUp Successful",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatRoom()),
      );
    } else {
      /// SignUp Failed
      Fluttertoast.showToast(
        msg: "Try Again, SignUp Failed.",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );
    }
  }

  /// Google SignUP and SignIN
  Future<void> signUpWithGoogle(BuildContext context) async {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    UserCredential result = await _auth.signInWithCredential(credential);
    User firebaseUser = result.user;

    /// SignIn Success
    if (firebaseUser != null) {
      QuerySnapshot resultQuery =
          await databaseMethods.getUserUserEmail(firebaseUser.email);
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      /// if  new user then Save Data to fireStore;
      if (documentSnapshots.length == 0) {
        ///  FireStore data in the form of map therefore we store the firebaseUser data as a map object which is defined in the loggedIN user class

        Map<String, dynamic> userMap = loggedInUser.toMap(firebaseUser);

        /// uploading data to the fireStore
        await databaseMethods.uploadUserInfo(firebaseUser.uid, userMap);

        /// write data to local sharedPreference

        var currentUser = firebaseUser;
        HelperFunctions.saveUserNameSharedPreference(currentUser.displayName);
        HelperFunctions.saveUserEmailSharedPreference(currentUser.email);
        HelperFunctions.saveUserPhotoUrlSharedPreference(currentUser.photoURL);
        HelperFunctions.saveUserAboutMeSharedPreference('I Love KeepCHATTING');
      }

      /// old user
      else {
        /// write data to local
        HelperFunctions.saveUserNameSharedPreference(
            documentSnapshots[0].data()["name"]);
        HelperFunctions.saveUserEmailSharedPreference(
            documentSnapshots[0].data()["email"]);
        HelperFunctions.saveUserPhotoUrlSharedPreference(
            documentSnapshots[0].data()["photoUrl"]);
        HelperFunctions.saveUserAboutMeSharedPreference(
            documentSnapshots[0].data()["aboutMe"]);
      }

      HelperFunctions.saveUserLoggedInSharedPreference(true);

      Fluttertoast.showToast(
        msg: "Congratulations, SignIn Successful",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatRoom()),
      );
    } else {
      /// SignIn Failed
      Fluttertoast.showToast(
        msg: "Try Again, Sign in Failed.",
        backgroundColor: Colors.lightBlueAccent,
        fontSize: 16.0,
      );
    }
  }

  /// sending a reset link to the given mail
  Future<void> resetPass(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  /// SignOut Function
  Future<void> signOut(BuildContext context) async {
    /// google signing out
    User user = _auth.currentUser;
    if (user.providerData[0].providerId == 'google.com') {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      // await googleSignIn.disconnect();
    } else {
      /// firebase auth signing out
      await _auth.signOut();
    }
    HelperFunctions.saveUserLoggedInSharedPreference(false);
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authenticate()),
    );
  }

  /// This function is for search screen and called in the initstate
  Future<List<LoggedInUser>> fetchAllUsers() async {
    List<LoggedInUser> usersList = List<LoggedInUser>();

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != _auth.currentUser.uid) {
        usersList.add(LoggedInUser.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return usersList;
  }
}
