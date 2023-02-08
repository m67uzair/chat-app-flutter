import 'dart:async';

import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/providers/auth_provider.dart';
import 'package:chat_app_flutter/screens/chat_screen.dart';
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
  int selectIndex = 0;
  void onItemTap(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Messages",
            style: TextStyle(fontFamily: "caros", fontSize: 25),
          ),
          centerTitle: true,
          leading: const Icon(Icons.search),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xff1E1E1E),
          ),
          backgroundColor: const Color(0xff1E1E1E),
          actions: [
            CircleAvatar(
              child: IconButton(
                onPressed: () async {
                  await authProvider.signOut();
                  navigatorKey.currentState!.popUntil((route) => route.isFirst);
                  // Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.person),
              ),
            )
          ],
        ),
        body: TabBarView(children: [
          Container(
            height: 300.0,
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  AssetImage("assets/images/m_uzair.png"),
                            ),
                            title: const Text(
                              "Muhammad Uzair",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                                      color: Color(0xFFF04A4C),
                                      shape: BoxShape.circle),
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
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => const ChatScreen(),
                              //     ));
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(child: const Icon(Icons.directions_transit)),
          Container(child: const Icon(Icons.directions_bike)),
          Container(child: const Icon(Icons.directions_bike)),
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
          //   onTap: onItemTap,
          // )
        ),
      ),
    );
  }
}
