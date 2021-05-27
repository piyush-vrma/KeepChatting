import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

/// This is our FirebaseFireStore DataBase

class DatabaseMethods {
  /// getting the userData by userName at the time of searching

  getUserUserName(String userName) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: userName)
        .get()
        .catchError((e) {
      print(e.toString());
    });

    /// we are using get() because it will return a Future Object of QuerySnapshot
  }

  /// getting the userData by userEmail at the time of logIn because
  /// we want the userName to save in the sharedPreference;

  getUserUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get()
        .catchError((e) {
      print(e.toString());
    });

    /// we are using get() because it will return a Future Object of QuerySnapshot
  }

  /// uploading the user data at the time of registration
  uploadUserInfo(String id, userMap) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  /// updating the user data at the time of account setting
  updateUserInfo(
      String id, String name, String aboutMe, String photoUrl) async {
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      "name": name,
      "aboutMe": aboutMe,
      "photoUrl": photoUrl,
    }).catchError((e) {
      print(e.toString());
    });
  }

  /// we can direct upload the data by random document by using add method
  /// or we can use a custom document id and upload the data using set method as done in the below function;

  /// This method will create a chat room ... and called in the search screen
  createChatRoom(String chatRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  /// This method is basically called when sendButton is clicked
  /// This method stores every message to the FireStore DataBase
  /// message will be stored in the collection called "chats" which will
  /// be created in the particular chatRoomId document ;

  addConversationMessages(String chatRoomId, messageMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  /// This method is called in the initState to get all the prior conversations of the particular chatroomid
  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();

    /// we are using snapshot() in place of get() because it will return Stream<QuerySnapshot>
  }

  /// This method is called to get all the users available
  /// it is called in the initState of the chat_room_screen
  getChatRooms(String userEmail) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("usersEmail", arrayContains: userEmail)
        .snapshots();

    /// we are using snapshot() in place of get() because it will return Stream<QuerySnapshot>
  }

  /// This is the pick Image Function . . . .
  Future<File> pickImage({@required ImageSource source}) async {
    /// The below file is the one picked from the given source and will be sent after compression
    PickedFile file = await ImagePicker().getImage(
        source: source, maxWidth: 500, maxHeight: 500, imageQuality: 85);
    File selectedImage = File(file.path);
    return selectedImage;
  }
}
