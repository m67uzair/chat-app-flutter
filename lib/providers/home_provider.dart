import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_constants.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateFirestoreData(String collectionPath, String path, Map<String, dynamic> updateData) {
    return firebaseFirestore.collection(collectionPath).doc(path).update(updateData);
  }

  Stream<QuerySnapshot> getFirestoreData(String collectionPath, int limit, String? textSearch) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.displayName, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore.collection(collectionPath).limit(limit).snapshots();
    }
  }

  Future<QuerySnapshot> getUserPhoto(String userId) async {
    return await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: userId)
        .get();
  }

  Future<List> getUsersChattedWith(String collectionPath, String userId) async {
    final docSnapshot = await firebaseFirestore
        .collection(collectionPath)
        .doc(userId)
        .get();
    return docSnapshot.get(FirestoreConstants.chattingWith);
  }

  Stream<QuerySnapshot> getFirestoreInboxData(String collectionPath, int limit, String userId) async* {
    print("functon called before await");
    List usersArray = await getUsersChattedWith(collectionPath, userId);
    print("functon called after await");
    yield* firebaseFirestore
        .collection(collectionPath)
        .where(FirestoreConstants.id, whereIn: usersArray)
        .snapshots();
  }
}
