import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:smart_talk/allConstants/all_constants.dart';
import 'package:chat_app_flutter/models/user_model.dart';

import '../constants/firestore_constants.dart';
import 'dart:core';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  // final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  User? firebaseUser;

  Status _status = Status.uninitialized;
  bool signInActivityDone = false;

  Status get status => _status;

  set setSignInActivity(value) {
    signInActivityDone = value;
    notifyListeners();
  }

  bool get getSignInActivity => signInActivityDone;

  AuthProvider({required this.firebaseAuth, required this.firebaseFirestore, required this.prefs});

  String? getFirebaseUserId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    if (firebaseUser != null && prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> signIn({required email, required password, required name, required phoneNumber}) async {
    try {
      final result = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ));

      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await prefs.setString(FirestoreConstants.phoneNumber, phoneNumber.toString());

      firebaseUser = FirebaseAuth.instance.currentUser;
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      firebaseUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      await prefs.setString(FirestoreConstants.phoneNumber, firebaseUser?.phoneNumber ?? "");
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<bool> handleSignIn() async {
    // prefs.reload();
    _status = Status.authenticating;
    notifyListeners();

    if (firebaseUser != null) {
      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.id, isEqualTo: firebaseUser!.uid)
          .get();

      final List<DocumentSnapshot> document = result.docs;
      if (document.isEmpty) {
        print("if executed");
        firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(firebaseUser!.uid).set({
          FirestoreConstants.displayName: firebaseUser!.displayName,
          FirestoreConstants.photoUrl: firebaseUser!.photoURL ?? "",
          FirestoreConstants.id: firebaseUser!.uid,
          "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.chattingWith: null,
          FirestoreConstants.phoneNumber: firebaseUser!.phoneNumber ?? ""
        });

        User? currentUser = firebaseUser;
        await prefs.setString(FirestoreConstants.id, currentUser!.uid);
        await prefs.setString(FirestoreConstants.displayName, currentUser.displayName ?? "");
        await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        if (currentUser.phoneNumber != null) {
          await prefs.setString(FirestoreConstants.phoneNumber, currentUser.phoneNumber.toString());
        }

        await prefs.setString(FirestoreConstants.aboutMe, "");
      } else {
        print("else executed");
        DocumentSnapshot documentSnapshot = document[0];
        ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
        print("variable user id $userChat.id");
        print("userId ${await prefs.setString(FirestoreConstants.id, userChat.id)}");
        await prefs.setString(FirestoreConstants.displayName, userChat.displayName);
        await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
        await prefs.setString(FirestoreConstants.phoneNumber, userChat.phoneNumber);
      }
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
