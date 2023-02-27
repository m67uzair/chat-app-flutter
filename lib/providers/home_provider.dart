import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_constants.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateFirestoreData(
      String collectionPath, String path, Map<String, dynamic> updateData) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(updateData);
  }

  Stream<QuerySnapshot> getFirestoreData(
      String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.displayName, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }

  Future<List> getUsersChattedWith(String collectionPath, String userId) async {
    return await firebaseFirestore
        .collection(collectionPath)
        .doc(userId)
        .get()
        .then((documentSnapshot) =>
            documentSnapshot.data()![FirestoreConstants.chattingWith]);
  }

  Stream<QuerySnapshot> getFirestoreInboxData(
      String collectionPath, int limit, String userId) async* {
    List usersArray = await getUsersChattedWith(collectionPath, userId);
    yield* firebaseFirestore
        .collection(collectionPath)
        .where(FirestoreConstants.id, whereIn: usersArray)
        .snapshots();
  }
}
