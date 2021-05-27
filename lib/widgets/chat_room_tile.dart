import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keep_chatting/screens/conversation_screen.dart';
import 'package:keep_chatting/screens/full_photo.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/widgets/widget_functions.dart';

import '../constants.dart';

class ChatRoomTile extends StatefulWidget {
  final String searchedUserEmail;
  final String chatRoomId;
  ChatRoomTile({this.chatRoomId, this.searchedUserEmail});

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  QuerySnapshot searchesUserSnapshot;
  String photoUrl;
  String searchedUserUserName;
  bool isLoading = true;

  getSearchedUserData() async {
    try {
      await databaseMethods
          .getUserUserEmail(widget.searchedUserEmail)
          .then((val) {
        setState(() {
          searchesUserSnapshot = val;
          photoUrl = searchesUserSnapshot.docs[0].data()['photoUrl'];
          searchedUserUserName = searchesUserSnapshot.docs[0].data()['name'];
          isLoading = false;
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.message);
    }
  }

  @override
  void initState() {
    getSearchedUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getSearchedUserData();
    return isLoading
        ? Container()
        : Container(
            color: Colors.black26,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullPhoto(
                                  photoUrl: photoUrl,
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 24, right: 24),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: photoUrl == ""
                          ? Text(
                              "${searchedUserUserName.substring(0, 1).toUpperCase()}",
                              style: kTextStyle.copyWith(fontSize: 20),
                            )
                          : userProfileImage(context, photoUrl),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                            userName: searchedUserUserName,
                            userProfilePic: photoUrl,
                            chatRoomId: widget.chatRoomId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            searchedUserUserName,
                            style: kTextStyle.copyWith(fontSize: 18),
                          ),
                          Text(
                            widget.searchedUserEmail,
                            style: kTextStyle.copyWith(
                                fontSize: 13, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
