import 'package:firebase_auth/firebase_auth.dart';

class LoggedInUser {
  String id;
  String name;
  String email;
  String photoUrl;
  String aboutMe;
  String createdAt;

  LoggedInUser({
    this.id,
    this.name,
    this.email,
    this.photoUrl,
    this.aboutMe,
    this.createdAt,
  });

  Map<String, dynamic> toMap(User firebaseUser, {String userName = ""}) {
    var data = Map<String, dynamic>();
    data["id"] = firebaseUser.uid;
    data["name"] = userName == "" ? firebaseUser.displayName : userName;
    data["email"] = firebaseUser.email;
    data["photoUrl"] =
        firebaseUser.photoURL != null ? firebaseUser.photoURL : "";
    data["aboutMe"] = "I Love KeepCHATTING";
    data["createdAt"] = DateTime.now().millisecondsSinceEpoch.toString();
    return data;
  }

  LoggedInUser.fromMap(Map<String, dynamic> mapData) {
    id = mapData["id"];
    name = mapData["name"];
    email = mapData["email"];
    photoUrl = mapData["photoUrl"];
    aboutMe = mapData["aboutMe"];
    createdAt = mapData["createdAt"];
  }
}
