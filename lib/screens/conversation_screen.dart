import 'dart:async';
import 'dart:io';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_chatting/constants.dart';
import 'package:keep_chatting/services/database.dart';
import 'package:keep_chatting/streams/message_stream.dart';
import 'package:keep_chatting/widgets/modal_tile.dart';
import 'package:keep_chatting/widgets/textField_button.dart';
import 'package:keep_chatting/widgets/widget_functions.dart';
import 'chat_room_screen.dart';
import 'full_photo.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

class ConversationScreen extends StatefulWidget {
  final userName;
  final userProfilePic;
  final chatRoomId;
  ConversationScreen({this.chatRoomId, this.userName, this.userProfilePic});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController messageController = TextEditingController();
  Stream chatMessagesStream;
  final FocusNode focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  File imageFile;
  String imageUrl;
  bool isLoading = false;
  bool isWriting = false;
  bool showEmojiPicker = false;
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  double accuracy = 1.0;

  @override
  void initState() {
    getNotification();
    getMessages();
    super.initState();
  }

  getNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  _listen() async {
    if (!isListening) {
      showKeyboard();
      bool available = await speech.initialize(
        onStatus: (val) => print('onStatus : $val'),
        onError: (val) => print('onError : $val'),
      );
      if (available) {
        setState(() {
          isWriting = true;
          isListening = true;
        });
        speech.listen(onResult: (val) {
          setState(() {
            messageController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              accuracy = val.confidence;
              print(accuracy);
            }
          });
        });
      }
    } else {
      hideKeyboard();
      setState(() {
        isWriting = false;
        isListening = false;
        speech.stop();
      });
    }
  }

  getMessages() async {
    await databaseMethods
        .getConversationMessages(widget.chatRoomId)
        .then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });
  }

  /// This method is basically called when sendButton is clicked
  void sendMessage(String contentMsg, int type) async {
    if (contentMsg.isNotEmpty || contentMsg != null) {
      Map<String, dynamic> messageMap = {
        "message": contentMsg,
        "sender": Constants.myEmail,
        "time": DateTime.now().millisecondsSinceEpoch,
        "DateTime": DateTime.now(),
        "type": type,
      };

      /// storing the data to the fireStore database;
      await databaseMethods.addConversationMessages(
          widget.chatRoomId, messageMap);
      setState(() {
        isWriting = false;
        messageController.clear();
      });
      scrollToBottom();
    } else {
      Fluttertoast.showToast(msg: "Empty Message.");
    }
  }

  customAppBar(context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullPhoto(
                                photoUrl: widget.userProfilePic,
                              )));
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: widget.userProfilePic == ""
                      ? Text(
                          "${widget.userName.substring(0, 1).toUpperCase()}",
                          style: kTextStyle.copyWith(fontSize: 20),
                        )
                      : userProfileImage(context, widget.userProfilePic),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                widget.userName,
                style: kTextStyle.copyWith(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 55,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: 40),
            child: IconButton(icon: Icon(Icons.video_call), onPressed: () {}),
          ),
          Container(
            child: IconButton(icon: Icon(Icons.phone), onPressed: () {}),
          ),
        ],
      ),
      elevation: 0.0,
      backgroundColor: Color(0xFF0A0E21),
    );
  }

  //
  Widget chatControls() {
    /// function which check the writing state
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    /// Media model called when add button is clicked
    addMediaModal(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF000000),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1D1E33),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        FlatButton(
                          child: Icon(
                            Icons.close,
                            color: kIconsColor,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Content and Tools',
                              style: kTextStyle.copyWith(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ModalTile(
                          title: 'Media',
                          subtitle: 'Share Photos and Videos',
                          icon: Icons.image,
                          onTap: () {
                            pickImage(source: ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                        ModalTile(
                          title: 'GIFS',
                          subtitle: 'Share gifs',
                          icon: Icons.gif,
                          onTap: () {
                            pickGif(context);
                          },
                        ),
                        ModalTile(
                          title: 'File',
                          subtitle: 'Share files',
                          icon: Icons.tab,
                          onTap: () {},
                        ),
                        ModalTile(
                          title: 'Contacts',
                          subtitle: 'Share Contacts',
                          icon: Icons.contacts,
                          onTap: () {},
                        ),
                        ModalTile(
                          title: 'Location',
                          subtitle: 'Share Location',
                          icon: Icons.add_location_alt,
                          onTap: () {},
                        ),
                        ModalTile(
                          title: 'Schedule Call',
                          subtitle: 'Arrange a call and get reminders',
                          icon: Icons.schedule,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    /// this is the main chatControls (add button + textfield + moreButtons + sendButtons)
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          /// Add button
          RoundIconButton(
            onPress: () {
              addMediaModal(context);
            },
            icon: Icons.add,
          ),
          SizedBox(
            width: 5,
          ),

          /// Text Field
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  onTap: () {
                    hideEmojiContainer();
                  },
                  focusNode: focusNode,
                  controller: messageController,
                  style: kTextStyle,
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: kHintTextStyle,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (!showEmojiPicker) {
                      /// keyBoard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      hideEmojiContainer();
                      showKeyboard();
                    }
                  },
                  icon: Icon(
                    Icons.face,
                    color: kIconsColor,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            ),
          ),

          /// Other IconButtons
          !isWriting
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: AvatarGlow(
                    animate: isListening,
                    glowColor: Theme.of(context).primaryColor,
                    endRadius: 25.0,
                    duration: Duration(milliseconds: 2000),
                    repeatPauseDuration: Duration(milliseconds: 100),
                    repeat: true,
                    child: RoundIconButton(
                      icon: Icons.mic,
                      onPress: () {
                        _listen();
                      },
                    ),
                  ),
                )
              : Container(),

          !isWriting
              ? RoundIconButton(
                  icon: Icons.camera_alt,
                  onPress: () => pickImage(source: ImageSource.camera),
                )
              : Container(),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: kIconsColor,
                      size: 20,
                    ),
                    onPressed: () {
                      sendMessage(messageController.text, 0);
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  pickGif(context) async {
    final gif = await GiphyPicker.pickGif(
      context: context,
      apiKey: 'NJ3sWVgjsgnZjpU64DZ1L1k4l7wpd6Ud',
      fullScreenDialog: false,
      previewType: GiphyPreviewType.previewWebp,
      decorator: GiphyDecorator(
        showAppBar: false,
        searchElevation: 4,
        giphyTheme: ThemeData.dark().copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );

    if (gif != null) {
      String gifUrl = gif.images.original.url;
      print(gifUrl);
      sendMessage(gifUrl, 1);
      Navigator.pop(context);
    }
  }

  pickImage({@required ImageSource source}) async {
    imageFile = await databaseMethods.pickImage(source: (source));
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
    }
    uploadImageFile();
  }

  Future<void> uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      isLoading = true;

      /// fs here means, FirebaseStorage class is written as fs
      fs.Reference storageReference = fs.FirebaseStorage.instance
          .ref()
          .child("Chat Images")
          .child(fileName);

      fs.UploadTask uploadTaskOnStorage = storageReference.putFile(imageFile);

      fs.TaskSnapshot taskSnapshot;

      uploadTaskOnStorage.then((value) {
        if (value != null) {
          taskSnapshot = value;
          taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) async {
            setState(() {
              imageUrl = newImageDownloadUrl;
              isLoading = false;
              sendMessage(imageUrl, 1);
            });
          }, onError: (errorMsg) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: 'Error occurred in getting Download Url');
          });
        }
      }, onError: (errorMsg) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: errorMsg.toString());
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        Fluttertoast.showToast(msg: e.message);
      });
    }
  }

  showKeyboard() => focusNode.requestFocus();
  hideKeyboard() => focusNode.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// Message Stream Implemented in the stream folder ///
          /// Here all our messages will be displayed
          Expanded(
            child: MessageStream(
              stream: chatMessagesStream,
              scrollController: _scrollController,
              isLoading: isLoading,
            ),
          ),

          /// Display the emoji
          showEmojiPicker
              ? Container(
                  child: emojiContainer(),
                )
              : Container(),

          /// Text Field with input controllers (emoji and image Buttons) ///
          chatControls(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: CupertinoColors.separator,
      indicatorColor: Colors.blue,
      rows: 3,
      columns: 7,
      recommendKeywords: ["racing", "horse", "faces"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
          messageController.text = messageController.text + emoji.emoji;
        });
        // print(emoji);
      },
    );
  }

  /// This function is called when we send a message
  void scrollToBottom() {
    _scrollController.animateTo(0.0,
        curve: Curves.easeInOut, duration: Duration(milliseconds: 500));
  }
}
