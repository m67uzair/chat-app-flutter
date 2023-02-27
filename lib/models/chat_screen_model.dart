import 'package:chat_app_flutter/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;
  bool readStatus;

  ChatMessages(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.type,
      required this.readStatus});

  Map<String, dynamic> toJason() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
      FirestoreConstants.readStatus: readStatus
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom =
        documentSnapshot.data().toString().contains(FirestoreConstants.idFrom)
            ? documentSnapshot.get(FirestoreConstants.idFrom) ?? ""
            : "";
    String idTo =
        documentSnapshot.data().toString().contains(FirestoreConstants.idTo)
            ? documentSnapshot.get(FirestoreConstants.idTo) ?? ""
            : "";
    String timestamp = documentSnapshot
            .data()
            .toString()
            .contains(FirestoreConstants.timestamp)
        ? documentSnapshot.get(FirestoreConstants.timestamp) ?? ""
        : "";

    String content =
        documentSnapshot.data().toString().contains(FirestoreConstants.content)
            ? documentSnapshot.get(FirestoreConstants.content) ?? ""
            : "";
    int type =
        documentSnapshot.data().toString().contains(FirestoreConstants.type)
            ? documentSnapshot.get(FirestoreConstants.type) ??
                int.parse(documentSnapshot.get(FirestoreConstants.type))
            : 0;

    bool readStatus = documentSnapshot
            .data()
            .toString()
            .contains(FirestoreConstants.readStatus)
        ? documentSnapshot.get(FirestoreConstants.readStatus) ??
            int.parse(documentSnapshot.get(FirestoreConstants.readStatus))
        : false;

    return ChatMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type,
        readStatus: readStatus);
  }
}
