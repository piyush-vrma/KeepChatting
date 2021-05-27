import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keep_chatting/screens/full_photo.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.time,
      this.message,
      this.isMe,
      this.type,
      this.isLoading,
      this.messageNumber});

  final String message;
  final String time;
  final bool isMe;
  final int type;
  final isLoading;
  final int messageNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          type == 1
              ? isLoading
                  ? Container(
                      width: 250.0,
                      height: 250.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPhoto(
                              photoUrl: message,
                            ),
                          ),
                        );
                      },
                      child: getImageMessage(context, message),
                    )
              : Material(
                  elevation: 5.0,
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        )
                      : BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                  color: isMe ? Colors.lightBlueAccent : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: type == 0 ? 10.0 : 14.0,
                      horizontal: type == 0 ? 15.0 : 1.0,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black54,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding:
                isMe ? EdgeInsets.only(right: 5) : EdgeInsets.only(left: 5),
            child: Text(
              time,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getImageMessage(context, photoUrl) {
    return Material(
      /// Display the image file
      child: CachedNetworkImage(
        placeholder: (context, photoUrl) => Container(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            strokeWidth: 2.0,
          ),
          width: 250,
          height: 250.0,
          padding: EdgeInsets.all(20.0),
        ),
        imageUrl: photoUrl,
        width: 250.0,
        height: 250.0,
        fit: BoxFit.cover,
        errorWidget: (context, photoUrl, error) => Material(
          child: Image.asset(
            'assets/images/NF.jgp',
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.hardEdge,
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
    );
  }
}
