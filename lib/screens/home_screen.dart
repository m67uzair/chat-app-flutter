import 'dart:async';

import 'package:chat_app_flutter/constants/firestore_constants.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/providers/auth_provider.dart';
import 'package:chat_app_flutter/screens/chat_screen.dart';
import 'package:chat_app_flutter/screens/profile_screen.dart';
import 'package:chat_app_flutter/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthProvider authProvider;
  late HomeProvider homeProvider;
  late final String currentUserId;

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
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ));
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
                onPressed: () async {
                  // await authProvider.signOut();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettingsScreen(),
                      ));
                },
                icon: const Icon(Icons.person),
              ),
            )
          ],
        ),
        body: TabBarView(children: [
          Container(
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
                              backgroundImage:
                                  AssetImage("assets/images/m_uzair.png"),
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
                          backgroundImage:
                              AssetImage("assets/images/profilePicture.png"),
                        ),
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("assets/images/profilePicture.png"),
                        ),
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("assets/images/profilePicture.png"),
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
                    child: StreamBuilder(
                      stream: homeProvider.getFirestoreInboxData(
                          FirestoreConstants.pathUserCollection,
                          20,
                          currentUserId),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if ((snapshot.data?.docs.length ?? 0) > 0) {
                            return ListView.separated(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => BuildItem(
                                  homeProvider: homeProvider,
                                  currentUserId: currentUserId),
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                            );
                          } else {
                            return const Center(
                              child: Text("No conversations yet.."),
                            );
                          }
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(child: const Icon(Icons.directions_transit)),
          Container(child: const Icon(Icons.directions_bike)),
          IconButton(
            icon: const Icon(Icons.directions_bike),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ]),
        bottomNavigationBar: const SizedBox(
          height: 80,
          child: TabBar(
            tabs: [
              Tab(
                  icon: Icon(
                    Icons.message_outlined,
                    color: Color(0xff1E1E1E),
                  ),
                  text: "messages"),
              Tab(
                  icon: Icon(
                    Icons.phone_outlined,
                    color: Color(0xff1E1E1E),
                  ),
                  text: "calls"),
              Tab(
                  icon: Icon(
                    Icons.people_outline,
                    color: Color(0xff1E1E1E),
                  ),
                  text: "contacts"),
              Tab(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Color(0xff1E1E1E),
                  ),
                  text: "settings"),
            ],
            indicatorColor: Color(0xff1E1E1E),
            labelColor: Color(0xff1E1E1E),
            indicatorWeight: 5.00,
          ),
          // BottomNavigationBar(
          //   type: BottomNavigationBarType.fixed,
          //   items: const [
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.message_outlined), label: "messages"),
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.phone_outlined), label: "calls"),
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.people_outline), label: "contacts"),
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.settings_outlined), label: "settings"),
          //   ],
          //   iconSize: 30.00,
          //   currentIndex: selectIndex,
          //   selectedItemColor: const Color(0xff1E1E1E),
          //   onTap: ,
          // )
        ),
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  const BuildItem({
    Key? key,
    required this.homeProvider,
    required this.currentUserId,
  }) : super(key: key);

  final HomeProvider homeProvider;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage("assets/images/m_uzair.png"),
      ),
      title: const Text(
        "Muhammad Uzair",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Hey how are you?"),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("2 min ago"),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: Color(0xFFF04A4C), shape: BoxShape.circle),
            child: const Center(
              child: Text(
                "3",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      onTap: () async {
        print(
            'CHATTING USERS ${await homeProvider.getFirestoreInboxData(FirestoreConstants.pathUserCollection, 20, currentUserId)}');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const ChatScreen(),
        //     ));
      },
    );
  }
}
