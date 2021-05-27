import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_chatting/helper/helper_functions.dart';
import 'package:keep_chatting/screens/chat_room_screen.dart';
import 'package:keep_chatting/services/auth.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/widgets/round_button.dart';
import '../constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios)),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF0A0E21),
        title: Text(
          'Account Setting',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SettingScreen(),
    );
  }
}

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  AuthMethods authMethods = AuthMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();
  final _formKey = GlobalKey<FormState>();
  String photoUrl = "";
  TextEditingController nameTextController = TextEditingController();
  TextEditingController aboutMeTextController = TextEditingController();
  File imageFileAvatar;
  bool isLoading = false;
  String _error;

  @override
  void initState() {
    readDataFromLocal();
    super.initState();
  }

  void readDataFromLocal() async {
    nameTextController.text =
        await HelperFunctions.getUserNameSharedPreference();
    aboutMeTextController.text =
        await HelperFunctions.getUserAboutMeSharedPreference();
    photoUrl = await HelperFunctions.getUserPhotoUrlSharedPreference();

    setState(() {});
  }

  Future<void> getImage() async {
    File newImageFile =
        await databaseMethods.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        imageFileAvatar = newImageFile;
        isLoading = true;
      });
      uploadImageToFireStoreAndStorage();
    }
  }

  /// Using this function we are updating our profile data in the account setting page;

  Future<void> uploadImageToFireStoreAndStorage() async {
    User user = _auth.currentUser;

    try {
      /// fs here means FirebaseStorage class is written as fs
      fs.Reference storageReference =
          fs.FirebaseStorage.instance.ref().child(user.email);

      fs.UploadTask uploadTask = storageReference.putFile(imageFileAvatar);

      fs.TaskSnapshot taskSnapshot;

      uploadTask.then((value) {
        if (value != null) {
          taskSnapshot = value;
          taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) async {
            setState(() {
              photoUrl = newImageDownloadUrl;
            });
            await databaseMethods
                .updateUserInfo(user.uid, nameTextController.text,
                    aboutMeTextController.text, photoUrl)
                .then((data) {
              HelperFunctions.saveUserNameSharedPreference(
                  nameTextController.text);
              HelperFunctions.saveUserAboutMeSharedPreference(
                  aboutMeTextController.text);
              HelperFunctions.saveUserPhotoUrlSharedPreference(photoUrl);
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: 'Updated Successfully.');
            });
          }, onError: (errorMsg) {
            Fluttertoast.showToast(
                msg: 'Error occurred in getting Download Url');
          });
        }
      }, onError: (errorMsg) {
        Fluttertoast.showToast(msg: errorMsg.toString());
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = e.message;
        Fluttertoast.showToast(msg: _error);
      });
    }
  }

  /// called when user pressed the update button . . .
  void updateData() async {
    try {
      User user = _auth.currentUser;
      await databaseMethods
          .updateUserInfo(user.uid, nameTextController.text,
              aboutMeTextController.text, photoUrl)
          .then((val) {
        HelperFunctions.saveUserNameSharedPreference(nameTextController.text);
        HelperFunctions.saveUserAboutMeSharedPreference(
            aboutMeTextController.text);
        HelperFunctions.saveUserPhotoUrlSharedPreference(photoUrl);
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Profile Updated Successfully.');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = e.message;
        Fluttertoast.showToast(msg: _error);
      });
    }
  }

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

  signOut() async {
    try {
      await authMethods.signOut(context);
    } catch (e) {
      setState(() {
        _error = e.message;
        print(_error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            showAlert(),

            /// Profile : Image > Avatar
            Container(
              child: Center(
                child: Stack(
                  children: [
                    (imageFileAvatar == null)
                        ? (photoUrl != "")
                            ? Material(
                                /// Display the old image file
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(20.0),
                                  ),
                                  imageUrl: photoUrl,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(125.0),
                                clipBehavior: Clip.hardEdge,
                              )
                            : Container(
                                height: 200.0,
                                width: 200.0,
                                child: Icon(
                                  /// if image is null then a icon is displayed to the user
                                  Icons.account_circle,
                                  size: 200.0,
                                  color: Colors.grey,
                                ),
                              )
                        : Material(
                            /// if the user click on the icon button to change the image then display the new updated image here
                            child: Image.file(
                              imageFileAvatar,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(125.0),
                            clipBehavior: Clip.hardEdge,
                          ),
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 100.0,
                        color: Colors.white54.withOpacity(0.3),
                      ),
                      onPressed: getImage,
                      padding: EdgeInsets.all(0.0),

                      /// all the buttons are having some padding so we are setting it to zero
                      splashColor: Colors.transparent,
                      highlightColor: Colors.grey,
                      iconSize: 200.0,
                    ),
                  ],
                ),
              ),
              width: double.infinity,
              margin: EdgeInsets.all(20.0),
            ),
            Padding(
              padding: EdgeInsets.all(1.0),
              child: isLoading
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : Container(),
            ),

            /// Input Fields . . .
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20.0,
                ),

                ///  User Name and About Me;
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
                        controller: nameTextController,
                        textAlign: TextAlign.center,
                        style: kTextStyle,
                        decoration: kAccountFieldTextFieldDecoration.copyWith(
                          labelText: 'Name',
                          hintText: 'Enter Your UserName',
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        validator: (bio) {
                          return (bio.length >= 50)
                              ? 'Bio must be less than 50 characters'
                              : null;
                        },
                        controller: aboutMeTextController,
                        textAlign: TextAlign.center,
                        style: kTextStyle,
                        decoration: kAccountFieldTextFieldDecoration.copyWith(
                          labelText: 'About Me',
                          hintText: 'Bio...',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                RoundButton(
                  color: Colors.blue,
                  text: 'Update',
                  textColor: Colors.white,
                  onPress: updateData,
                ),
                RoundButton(
                  color: Colors.white,
                  text: 'LogOut',
                  textColor: Colors.black,
                  onPress: () {
                    signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
