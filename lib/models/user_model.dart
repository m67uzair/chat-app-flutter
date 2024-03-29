import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_constants.dart';
// import 'package:smart_talk/allConstants/all_constants.dart';

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;

  const ChatUser(
      {required this.id,
      required this.photoUrl,
      required this.displayName,
      required this.phoneNumber,
      required this.aboutMe});

  ChatUser copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? phoneNumber,
    String? email,
  }) =>
      ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          aboutMe: email ?? aboutMe);

  Map<String, dynamic> toJson() => {
        FirestoreConstants.displayName: displayName,
        FirestoreConstants.photoUrl: photoUrl,
        FirestoreConstants.phoneNumber: phoneNumber,
        FirestoreConstants.aboutMe: aboutMe,
      };

  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String aboutMe = "";

    try {
      photoUrl = snapshot.data().toString().contains(FirestoreConstants.photoUrl)
          ? snapshot.get(FirestoreConstants.photoUrl) ?? ""
          : "";
      nickname = snapshot.data().toString().contains(FirestoreConstants.displayName)
          ? snapshot.get(FirestoreConstants.displayName) ?? ""
          : "";
      phoneNumber = snapshot.data().toString().contains(FirestoreConstants.phoneNumber)
          ? snapshot.get(FirestoreConstants.phoneNumber) ?? 0
          : 0;
      aboutMe = snapshot.data().toString().contains(FirestoreConstants.aboutMe)
          ? snapshot.get(FirestoreConstants.aboutMe) ?? ""
          : "";
      print("${nickname} contains photo url ${snapshot.data().toString().contains(FirestoreConstants.photoUrl)}");
      print("${nickname} get photo url ${snapshot.get(FirestoreConstants.photoUrl)}");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.id, photoUrl: photoUrl, displayName: nickname, phoneNumber: phoneNumber, aboutMe: aboutMe);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, photoUrl, displayName, phoneNumber, aboutMe];
}
