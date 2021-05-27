import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_chatting/constants.dart';

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  ModalTile({
    this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ListTile(
          leading: Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFF8D8E98),
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 38,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: kTextStyle.copyWith(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          title: Text(
            title,
            style: kTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
