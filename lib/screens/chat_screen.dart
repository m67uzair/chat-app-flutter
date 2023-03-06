import 'dart:io';
import 'dart:developer';
import 'package:chat_app_flutter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common_widgets.dart';
import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../constants/size_constants.dart';
import '../constants/text_field_constants.dart';
import '../models/chat_screen_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';

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

  bool currentPath = false;

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
    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection, currentUserId, {
      FirestoreConstants.chattingWith: FieldValue.arrayUnion([widget.peerId])
    });
    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection, widget.peerId, {
      FirestoreConstants.chattingWith: FieldValue.arrayUnion([currentUserId])
    });
  }

  @override
  Widget build(BuildContext context) {
    navigatorKey.currentState!.popUntil(
      (route) {
        currentPath = route.isCurrent;
        return true;
      },
    );
    // if (currentPath) {
    //   print("current path $currentPath");
    // }
    // print();
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData.fallback(),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: IconButton(
              onPressed: () {
                ProfileProvider profileProvider;
                profileProvider = context.read<ProfileProvider>();
                String callPhoneNumber =
                    profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
                _callPhoneNumber(callPhoneNumber);
              },
              icon: const Icon(Icons.call_sharp),
              color: const Color(0xff000E08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 15),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.videocam_outlined,
                color: Color(0xff000E08),
              ),
            ),
          )
        ],
        title: ListTile(
          leading: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage("assets/images/m_uzair.png"),
          ),
          title: Text(
            widget.peerNickname,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: groupChatId.isNotEmpty
                    ? StreamBuilder<QuerySnapshot>(
                        stream: chatProvider.getChatMessage(groupChatId, _limit),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            listMessages = snapshot.data!.docs;
                            if (listMessages.isNotEmpty) {
                              print("no no");

                              return ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: snapshot.data?.docs.length,
                                  reverse: true,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    if (isMessageReceived(index) && currentPath) {
                                      print("yes yes");
                                      chatProvider.updateReadReciepts(
                                          groupChatId, widget.peerId, _limit);
                                    }
                                    return BuildItem(
                                      currentUserId: currentUserId,
                                      isRecieved: isMessageReceived(index),
                                      documentSnapshot: snapshot.data?.docs[index],
                                    );
                                  });
                            } else {
                              return const Center(
                                child: Text('No messages...'),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.burgundy,
                              ),
                            );
                          }
                        })
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.burgundy,
                        ),
                      ),
              ),
              buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageInput() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: getImage,
              icon: const Icon(
                Icons.camera_alt,
                size: Sizes.dimen_28,
              ),
              color: AppColors.white,
            ),
          ),
          Flexible(
              child: TextField(
            focusNode: focusNode,
            textInputAction: TextInputAction.send,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: textEditingController,
            decoration: kTextInputDecoration.copyWith(hintText: 'write here...'),
            onSubmitted: (value) {
              onSendMessage(textEditingController.text, MessageType.text);
            },
          )),
          Container(
            margin: const EdgeInsets.only(left: Sizes.dimen_4),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
            ),
            child: IconButton(
              onPressed: () {
                onSendMessage(textEditingController.text, MessageType.text);
              },
              icon: const Icon(Icons.send_rounded),
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildListMessage() {
  //   return ;
  // }

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
      chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection, currentUserId,
          {FirestoreConstants.chattingWith: null});
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
      chatProvider.sendChatMessage(content, type, groupChatId, currentUserId, widget.peerId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(0,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  // checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 && listMessages[index].get(FirestoreConstants.idFrom) == currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.idFrom) != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}

// Future<String> getUserPhoto() async {
//   QuerySnapshot userSnapshot = await homeProvider.getUserPhoto(currentUserId);
//   List dataList =
//       userSnapshot.docs.map((DocumentSnapshot doc) => doc.data()).toList();
//   return dataList[0][FirestoreConstants.photoUrl];
// }

class BuildItem extends StatefulWidget {
  final bool isRecieved;
  final DocumentSnapshot? documentSnapshot;
  final String currentUserId;

  const BuildItem({
    super.key,
    required this.isRecieved,
    required this.currentUserId,
    this.documentSnapshot,
  });

  @override
  State<BuildItem> createState() => _BuildItemState();
}

class _BuildItemState extends State<BuildItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.documentSnapshot != null) {
      ChatMessages chatMessages = ChatMessages.fromDocument(widget.documentSnapshot!);
      // if (widget.isRecieved) {
      //   print('ok');
      // }

      if (chatMessages.idFrom == widget.currentUserId) {
        // right side (my message)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                chatMessages.type == MessageType.text
                    ? Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: senderMessageBubble(
                            chatContent: chatMessages.content,
                            color: AppColors.spaceLight,
                            textColor: AppColors.white,
                            readStatus: chatMessages.readStatus,
                            timestamp: chatMessages.timestamp),
                      )
                    : chatMessages.type == MessageType.image
                        ? Container(
                            margin:
                                const EdgeInsets.only(right: Sizes.dimen_10, top: Sizes.dimen_10),
                            child: chatImage(imageSrc: chatMessages.content, onTap: () {}),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                chatMessages.type == MessageType.text
                    ? Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: recieverMessageBubble(
                            color: AppColors.burgundy,
                            textColor: AppColors.white,
                            chatContent: chatMessages.content,
                            readStatus: chatMessages.readStatus,
                            timestamp: chatMessages.timestamp),
                      )
                    : chatMessages.type == MessageType.image
                        ? Container(
                            margin:
                                const EdgeInsets.only(left: Sizes.dimen_10, top: Sizes.dimen_10),
                            child: chatImage(imageSrc: chatMessages.content, onTap: () {}),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}

// Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {}
