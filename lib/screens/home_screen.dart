import 'package:chat_app_flutter/constants/firestore_constants.dart';
import 'package:chat_app_flutter/providers/auth_provider.dart';
import 'package:chat_app_flutter/screens/extract_arguments_screen.dart';
import 'package:chat_app_flutter/screens/profile_screen.dart';
import 'package:chat_app_flutter/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/home_provider.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthProvider authProvider;
  late HomeProvider homeProvider;

  int selectIndex = 0;

  void onItemTap(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
  }

  // if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
  // if (authProvider.getSignInActivity) {
  // currentUserId = authProvider.getFirebaseUserId() ?? "";
  // }
  // print("current user ${currentUserId}");
  // }

  @override
  Widget build(BuildContext context) {
    // final userStream = Provider.of<HomeProvider>(context)
    //     .getFirestoreInboxData(FirestoreConstants.pathUserCollection, 20, currentUserId);
    print("build called");
    final userStream =
        homeProvider.getFirestoreInboxData(FirestoreConstants.pathUserCollection, 20, widget.currentUserId!);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                )).then((value) => setState(() {}));
          },
          icon: const Icon(Icons.search),
        ),
        title: const Text(
          "Messages",
          style: TextStyle(fontFamily: "caros", fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff1E1E1E),
        ),
        backgroundColor: const Color(0xff1E1E1E),
        actions: [
          CircleAvatar(
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ));
              },
              icon: const Icon(Icons.person),
            ),
          ),
          IconButton(
              onPressed: () async {
                await authProvider.signOut();
              },
              icon: const Icon(Icons.exit_to_app_rounded))
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 200,
        color: const Color(0xff1E1E1E),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage("assets/images/m_uzair.png"),
                        ),
                        Text(
                          "My Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/man.jpg"),
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/profilePicture.png"),
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/profilePicture.png"),
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/profilePicture.png"),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: StreamBuilder(
                    stream: userStream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print("builder called");
                      if (snapshot.connectionState == ConnectionState.active) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.separated(
                            itemCount: snapshot.data!.docs.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) =>
                                BuildItem(context: context, documentSnapshot: snapshot.data!.docs[index]),
                          );
                        } else {
                          return const Center(
                            child: Text("No conversations yet.."),
                          );
                        }
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Center(
                          child: Text("No conversations yet.."),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  const BuildItem({
    Key? key,
    required this.context,
    required this.documentSnapshot,
  }) : super(key: key);

  final BuildContext context;
  final DocumentSnapshot documentSnapshot;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    ChatUser chatUser = ChatUser.fromDocument(documentSnapshot);
    String? currentUser = firebaseAuth.currentUser?.uid;
    final lastMessageRef = documentSnapshot.get(FirestoreConstants.chattingWith)["lastMessage"][currentUser];
    print("reference $lastMessageRef");
    String numberOfUnreadMessages = lastMessageRef["numberOfUnreadMessages"].toString();
    return ListTile(
      leading: chatUser.photoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                chatUser.photoUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent,
                        value: loadingProgress.expectedTotalBytes != null
                            ? (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_circle,
                  size: 50,
                ),
              ),
            )
          : const Icon(Icons.account_circle, size: 50),
      title: Text(
        chatUser.displayName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(lastMessageRef["idFrom"] == currentUser
          ? "you: ${lastMessageRef["content"]}"
          : "${chatUser.displayName}: ${lastMessageRef["content"]}"),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("2 min ago"),
          int.parse(numberOfUnreadMessages) != 0
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Color(0xFFF04A4C), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      numberOfUnreadMessages,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: 24, height: 24)
        ],
      ),
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                  peerNickname: chatUser.displayName,
                  peerAvatar: chatUser.photoUrl,
                  peerId: chatUser.id,
                  userAvatar: firebaseAuth.currentUser?.photoURL ?? ""),
            ));
      },
    );
  }
}
