import 'package:chat_app_flutter/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  ChatMessages(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.type});

  Map<String, dynamic> toJason() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom =
        documentSnapshot.toString().contains(FirestoreConstants.idFrom)
            ? documentSnapshot.get(FirestoreConstants.idFrom) ?? ""
            : "";
    String idTo = documentSnapshot.toString().contains(FirestoreConstants.idTo)
        ? documentSnapshot.get(FirestoreConstants.idTo) ?? ""
        : "";
    String timestamp =
        documentSnapshot.toString().contains(FirestoreConstants.timestamp)
            ? documentSnapshot.get(FirestoreConstants.timestamp) ?? ""
            : "";
    String content =
        documentSnapshot.toString().contains(FirestoreConstants.content)
            ? documentSnapshot.get(FirestoreConstants.content) ?? ""
            : "";
    int type = documentSnapshot.toString().contains(FirestoreConstants.type)
        ? documentSnapshot.get(FirestoreConstants.type) ??
            int.parse(documentSnapshot.get(FirestoreConstants.type))
        : 0;

    return ChatMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type);
  }
}
