import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/message_bubble_tile.dart';

class MessageStream extends StatelessWidget {
  final stream;
  final scrollController;
  final isLoading;

  MessageStream({
    this.scrollController,
    this.stream,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(),
          );
        }
        return ListView.builder(
          reverse: true,
          shrinkWrap: true,
          controller: scrollController,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            final messages = snapshot.data.docs;
            int messageNumber = messages.length;
            String message = messages[index].data()["message"];
            String sender = messages[index].data()["sender"];
            Timestamp dateTime = messages[index].data()["DateTime"];
            String formattedTime = DateFormat.jm().format(dateTime.toDate());
            int type = messages[index].data()["type"];
            return MessageBubble(
              message: message,
              messageNumber: messageNumber,
              isMe: sender == Constants.myEmail,
              time: formattedTime,
              isLoading: isLoading,
              type: type,
            );
          },
        );
      },
    );
  }
}
