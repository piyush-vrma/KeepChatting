import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:keep_chatting/helper/helper_functions.dart';
import 'package:keep_chatting/screens/account_setting_screen.dart';
import 'package:keep_chatting/screens/search.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/widgets/round_button.dart';
import 'package:keep_chatting/streams/chat_room_stream.dart';

import '../constants.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  Stream chatRoomStream;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
    await databaseMethods.getChatRooms(Constants.myEmail).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
              child: Image.asset('assets/images/chat.png'),
            ),
          ),
          title: Row(
            children: [
              Text(
                'Keep',
                style: kTextStyle.copyWith(
                  fontSize: 14,
                  color: Color(0xFFEB1555),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'CHATTING',
                style: kTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
                padding: EdgeInsets.only(right: 10),
                icon: Icon(
                  Icons.settings,
                  color: Color(0xFFEB1555),
                  size: 30,
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()))),
          ],
          elevation: 0.0,
          backgroundColor: Color(0xFF0A0E21),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.6,
                bottom: MediaQuery.of(context).size.height * 0.015,
              ),
              child: Text(
                'CHATS',
                style: kTextStyle.copyWith(
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        body: ChatRoomStream(
          stream: chatRoomStream,
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to exit an App'),
          actions: [
            RoundButton(
              color: Colors.lightBlueAccent,
              textColor: Colors.white,
              text: 'No',
              onPress: () => Navigator.of(context).pop(false),
            ),
            RoundButton(
              color: Colors.white54,
              textColor: Colors.black,
              text: 'Yes',
              onPress: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
