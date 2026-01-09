import 'dart:convert';

class SavedAccountModel {
  final String uid;
  final String email;
  final String password;
  final String displayName;
  final String? photoUrl;
  final String? accessToken;
  final String? idToken;

  SavedAccountModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
    this.photoUrl,
    this.accessToken,
    this.idToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
      'idToken': idToken,
    };
  }

  factory SavedAccountModel.fromMap(Map<String, dynamic> map) {
    return SavedAccountModel(
      uid: map['uid'],
      email: map['email'],
      password: map['password'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      accessToken: map['accessToken'],
      idToken: map['idToken'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedAccountModel.fromJson(String source) => SavedAccountModel.fromMap(json.decode(source));
}
