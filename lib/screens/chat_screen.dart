import 'dart:io';
import 'package:chat_app_flutter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
  List<QueryDocumentSnapshot> listMessages = [];

  late String currentUserId;
  String groupChatId = '';
  String message = '';
  int _limit = 20;

  final int _limitIncrement = 20;

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
      "${FirestoreConstants.chattingWith}.users": FieldValue.arrayUnion([widget.peerId]),
      "${FirestoreConstants.chattingWith}.lastMessage.${widget.peerId}.numberOfUnreadMessages": 0,
    });

    chatProvider.updateFirestoreData(FirestoreConstants.pathUserCollection, widget.peerId, {
      "${FirestoreConstants.chattingWith}.users": FieldValue.arrayUnion([currentUserId]),
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
        automaticallyImplyLeading: false,
        titleSpacing: 0.1,
        iconTheme: const IconThemeData.fallback(),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: IconButton(
              onPressed: () {
                ProfileProvider profileProvider;
                profileProvider = context.read<ProfileProvider>();
                String callPhoneNumber = profileProvider.getPrefs(FirestoreConstants.phoneNumber) ?? "";
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
        title: SizedBox(
          width: double.infinity,
          child: ListTile(
            // minLeadingWidth: 10,
            horizontalTitleGap: 2,
            leading: widget.peerAvatar.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      widget.peerAvatar,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null),
                          );
                        }
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return const Icon(Icons.account_circle, size: 60);
                      },
                    ),
                  )
                : const Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
            title: Text(
              widget.peerNickname,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
            ),
            onTap: () {},
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              groupChatId.isNotEmpty
                  ? Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: chatProvider.getChatMessage(groupChatId, _limit),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            listMessages = snapshot.data!.docs;
                            if (listMessages.isNotEmpty) {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: snapshot.data?.docs.length,
                                  reverse: true,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    if (isMessageReceived(index) && currentPath) {
                                      chatProvider.updateReadReciepts(groupChatId, widget.peerId, _limit);
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
                        }),
                  )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
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
              color: const Color(0xFF20A090),
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
              color: const Color(0xFF20A090),
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
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
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
      chatProvider.updateFirestoreData(
          FirestoreConstants.pathUserCollection, currentUserId, {FirestoreConstants.chattingWith: null});
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

  void onSendMessage(String content, int type) async {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();

      await chatProvider.sendChatMessage(content, type, groupChatId, currentUserId, widget.peerId);

      QuerySnapshot lastMessageSnapshot = await chatProvider.getLastMessage(groupChatId);
      int numberOfUnreadMessages = await chatProvider.getNumberOfUnreadMessages(groupChatId);

      final lastMessage = lastMessageSnapshot.docs[0].data();

      await chatProvider.updateFirestoreData(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {
          "${FirestoreConstants.chattingWith}.lastMessage.${widget.peerId}": lastMessage,
          "${FirestoreConstants.chattingWith}.lastMessage.${widget.peerId}.numberOfUnreadMessages":
              numberOfUnreadMessages
        },
      );

      await chatProvider.updateFirestoreData(
        FirestoreConstants.pathUserCollection,
        widget.peerId,
        {
          "${FirestoreConstants.chattingWith}.lastMessage.$currentUserId": lastMessage,
          "${FirestoreConstants.chattingWith}.lastMessage.$currentUserId.numberOfUnreadMessages": 0
        },
      );
      print("updated number of unread messages");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: Colors.grey);
    }
  }

  // checking if received message
  bool isMessageReceived(int index) {
    if ((index > 0 && listMessages[index].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // checking if sent message
  bool isMessageSent(int index) {
    if ((index > 0 && listMessages[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
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

      if (chatMessages.idFrom == widget.currentUserId) {
        // right side (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            chatMessages.type == MessageType.text
                ? Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: senderMessageBubble(
                        chatContent: chatMessages.content,
                        color: const Color(0xFF20A090),
                        textColor: AppColors.white,
                        readStatus: chatMessages.readStatus,
                        timestamp: chatMessages.timestamp),
                  )
                : chatMessages.type == MessageType.image
                    ? Container(
                        margin: const EdgeInsets.only(right: Sizes.dimen_10, top: Sizes.dimen_10),
                        child: chatImage(imageSrc: chatMessages.content, onTap: () {}),
                      )
                    : const SizedBox.shrink(),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            chatMessages.type == MessageType.text
                ? Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: recieverMessageBubble(
                        color: const Color(0xFFE0EDF8),
                        textColor: Colors.black,
                        chatContent: chatMessages.content,
                        readStatus: chatMessages.readStatus,
                        timestamp: chatMessages.timestamp),
                  )
                : chatMessages.type == MessageType.image
                    ? Container(
                        margin: const EdgeInsets.only(left: Sizes.dimen_10, top: Sizes.dimen_10),
                        child: chatImage(imageSrc: chatMessages.content, onTap: () {}),
                      )
                    : const SizedBox.shrink(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}

// Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {}
