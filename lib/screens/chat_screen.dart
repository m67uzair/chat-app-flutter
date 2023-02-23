import 'dart:io';

import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/firestore_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String userAvatar;

  const ChatScreen(
      {super.key,
      required this.peerNickname,
      required this.peerAvatar,
      required this.peerId,
      required this.userAvatar});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String currentUserId;
  List<QueryDocumentSnapshot> listMessages = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = '';

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChanged);
    scrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    if (currentUserId.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId - ${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId} - $currentUserId';
    }
    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: widget.peerId});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadImageFile();
      }
    }
  }

  void uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadImageFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, MessageType.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future<bool> onBackPressed() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection,
          currentUserId, {FirestoreConstants.chattingWith: null});
    }
    return Future.value(false);
  }

  void _callPhoneNumber(String phoneNumber) async {
    var url = Uri(scheme: 'tel', path: "tel://$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Error Occurred';
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendChatMessage(
          content, type, groupChatId, currentUserId, widget.peerId);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  // checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 &&
            listMessages[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 &&
            listMessages[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List truth = [true, false, true, false];
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData.fallback(),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
        ),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Icon(
              Icons.call_sharp,
              color: Color(0xff000E08),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 15),
            child: Icon(
              Icons.videocam_outlined,
              color: Color(0xff000E08),
            ),
          )
        ],
        title: ListTile(
          leading: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage("assets/images/m_uzair.png"),
          ),
          title: const Text(
            "Muhammad Uzair",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Active Now"),
          // trailing: Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     const Text("2 min ago"),
          //     Container(
          //       width: 24,
          //       height: 24,
          //       decoration: const BoxDecoration(
          //           color: Color(0xFFF04A4C), shape: BoxShape.circle),
          //       child: const Center(
          //         child: Text(
          //           "3",
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     )
          //   ],
          // ),
          onTap: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: UnconstrainedBox(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff20A090),
                  ),
                  child: const Text("Hello, john"),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: UnconstrainedBox(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff20A090),
                  ),
                  child: const Text("Hello, Muhammad Uzair"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
