import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/chat_room_tile.dart';

class ChatRoomStream extends StatelessWidget {
  final stream;
  ChatRoomStream({this.stream});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  String searchedUserEmail = snapshot.data.docs[index]
                      .data()["chatroomid"]
                      .replaceAll("_", "")
                      .replaceAll(Constants.myEmail, "");
                  String chatRoomId =
                      snapshot.data.docs[index].data()["chatroomid"];
                  return ChatRoomTile(
                    searchedUserEmail: searchedUserEmail,
                    chatRoomId: chatRoomId,
                  );
                })
            : Container();
      },
    );
  }
}
