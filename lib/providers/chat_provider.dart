import 'dart:io';

import 'package:chat_app_flutter/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_app_flutter/models/chat_screen_model.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({
    required this.prefs,
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  UploadTask uploadImageFile(File image, String filename) {
    Reference reference = firebaseStorage.ref().child(filename);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateFirestoreData(String collectionPath, String userID, Map<String, dynamic> updatedData) {
    return firebaseFirestore.collection(collectionPath).doc(userID).update(updatedData);
  }

  void updateReadReciepts(String groupChatId, String recieverId, int limit) async {
    await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .where(FirestoreConstants.readStatus, isEqualTo: false)
        .where(FirestoreConstants.idFrom, isEqualTo: recieverId)
        .limit(limit)
        .get()
        .then((querySnapshot) => {
              for (var docSnapshot in querySnapshot.docs)
                {
                  docSnapshot.reference.update({FirestoreConstants.readStatus: true})
                }
            });
  }

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessage(String groupChatId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(1)
        .get();
  }

  Future<int> getNumberOfUnreadMessages(String groupChatId) async{
    QuerySnapshot querySnapshot = await  firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .where(FirestoreConstants.readStatus, isEqualTo: false).get();

    return querySnapshot.docs.length;
  }

  void updateUnreadMessagesCount(String groupChatId) async {
    DocumentSnapshot countDocSnapshot = await firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc("unreadMessagesCount")
        .get();

    int count = countDocSnapshot.get("count") ?? 0;

    firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc("unreadMessagesCount")
        .set({"count": count++});
  }

  void makeUnreadCountZero(String groupChatId)  {
    firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc("unreadMessagesCount")
        .set({"count": 0});
  }

  Future<void> sendChatMessage(String content, int type, String groupChatId, String currentUserId, String peerId)
  async {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().microsecondsSinceEpoch.toString());

    ChatMessages chatMessages = ChatMessages(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type,
        readStatus: false);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, chatMessages.toJason());
    });
  }
}

class MessageType {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
