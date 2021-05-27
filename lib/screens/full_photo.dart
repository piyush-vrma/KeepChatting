import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keep_chatting/constants.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  final String photoUrl;
  FullPhoto({this.photoUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'FULL IMAGE',
          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(
        photoUrl: photoUrl,
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final photoUrl;
  FullPhotoScreen({this.photoUrl});
  @override
  _FullPhotoScreenState createState() => _FullPhotoScreenState();
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  bool isLoading = true;
  @override
  void initState() {
    Timer(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          )
        : PhotoView(
            imageProvider: NetworkImage(widget.photoUrl),
          );
  }
}
