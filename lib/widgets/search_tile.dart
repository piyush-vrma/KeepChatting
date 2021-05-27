import 'package:flutter/material.dart';
import 'package:keep_chatting/widgets/round_button.dart';
import 'package:keep_chatting/widgets/widget_functions.dart';

import '../constants.dart';

class SearchListTile extends StatefulWidget {
  final userName;
  final email;
  final photoUrl;
  final Function onPress;

  SearchListTile({this.onPress, this.photoUrl, this.userName, this.email});

  @override
  _SearchListTileState createState() => _SearchListTileState();
}

class _SearchListTileState extends State<SearchListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(40),
            ),
            child: widget.photoUrl == ""
                ? Text(
                    "${widget.userName.substring(0, 1).toUpperCase()}",
                    style: kTextStyle.copyWith(fontSize: 20),
                  )
                : userProfileImage(context, widget.photoUrl),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: kTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              Text(
                widget.email,
                style: kTextStyle.copyWith(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            // padding: EdgeInsets.only(top: 8),
            child: RoundButton(
              text: 'Message',
              textColor: Colors.white,
              color: Colors.blue,
              onPress: widget.onPress,
            ),
          )
        ],
      ),
    );
  }
}
