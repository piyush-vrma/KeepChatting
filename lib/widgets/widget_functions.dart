import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_chatting/constants.dart';

Widget newAppBar(BuildContext context) {
  return AppBar(
    title: Row(
      children: [
        Container(
          height: 20,
          child: Image.asset('assets/images/chat.png'),
        ),
        SizedBox(
          width: 8,
        ),
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
    elevation: 0.0,
    backgroundColor: Color(0xFF0A0E21),
  );
}

/// Will return the Widget which Display the image File;
Widget userProfileImage(BuildContext context, String photoUrl) {
  return Material(
    /// Display the image file
    child: CachedNetworkImage(
      placeholder: (context, photoUrl) => Container(
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
  );
}
