import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keep_chatting/constants.dart';
import 'package:keep_chatting/models/logged_in_user.dart';
import 'package:keep_chatting/screens/conversation_screen.dart';
import 'package:keep_chatting/services/auth.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/widgets/search_tile.dart';

import 'chat_room_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController searchTextEditingController = TextEditingController();
  List<LoggedInUser> usersList;
  String query = "";

  @override
  void initState() {
    getUserList();
    super.initState();
  }

  getUserList() async {
    await authMethods.fetchAllUsers().then((list) {
      setState(() {
        usersList = list;
      });
    });
  }

  /// we have to move the user to the conversation screen by pushReplacement method

  createChatRoomAndStartConversation(String searchedPersonUserName,
      String searchedPersonEmail, String searchedPersonPhotoUrl) {
    if (searchedPersonEmail != Constants.myEmail) {
      String chatRoomId = getChatRoomID(searchedPersonEmail, Constants.myEmail);
      List<String> users = [searchedPersonUserName, Constants.myName];
      List<String> usersEmail = [searchedPersonEmail, Constants.myEmail];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "usersEmail": usersEmail,
        "chatroomid": chatRoomId,
      };
      databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(
            userName: searchedPersonUserName,
            userProfilePic: searchedPersonPhotoUrl,
            chatRoomId: chatRoomId,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "You can't message yourself !!");
    }
  }

  buildSuggestions(String query) {
    /// Here what we are doing is we are creating a list according to our query
    /// if half of the userName contains the query and have the same starting letter then that user is added in the suggestions list

    final List<LoggedInUser> suggestionList = query.isEmpty
        ? []
        : usersList.where((loggedInUser) {
            String _query = query.toLowerCase();
            String _name = loggedInUser.name.toLowerCase();
            bool matchesName = _name.contains(_query);
            bool matchesFirstLetter = _name.substring(0, 1).codeUnitAt(0) ==
                _query.substring(0, 1).codeUnitAt(0);
            return (matchesName && matchesFirstLetter);
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        LoggedInUser searchedUser = LoggedInUser(
          id: suggestionList[index].id,
          name: suggestionList[index].name,
          email: suggestionList[index].email,
          photoUrl: suggestionList[index].photoUrl,
        );
        return SearchListTile(
          userName: searchedUser.name,
          photoUrl: searchedUser.photoUrl,
          email: searchedUser.email,
          onPress: () {
            createChatRoomAndStartConversation(
              searchedUser.name,
              searchedUser.email,
              searchedUser.photoUrl,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: TextField(
              controller: searchTextEditingController,
              onChanged: (val) {
                setState(() {
                  query = val;
                });
              },
              cursorColor: Colors.white,
              autofocus: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 35,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => searchTextEditingController.clear());
                  },
                ),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: kTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Colors.white54),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Color(0xFF0A0E21),
            ),
            child: buildSuggestions(query),
          ),
        ],
      ),
    );
  }
}

/// This is the function which generate the same chatRoomId for both the users
getChatRoomID(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
