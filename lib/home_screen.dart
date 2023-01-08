import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
          centerTitle: true,
          leading: const Icon(Icons.search),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xff1E1E1E),
          ),
          backgroundColor: const Color(0xff1E1E1E),
          actions: const [
            CircleAvatar(
              child: Icon(Icons.person),
            )
          ],
        ),
        body: TabBarView(children: [
          Container(
            height: 300.0,
            color: const Color(0xff1E1E1E),
            child: Column(
              children: [
                SingleChildScrollView(
                    child: Row(children: const [
                  CircleAvatar(child: Icon(Icons.person)),
                  CircleAvatar(child: Icon(Icons.person)),
                  CircleAvatar(child: Icon(Icons.person)),
                  CircleAvatar(child: Icon(Icons.person)),
                ])),
                Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          )),
                      child: const Center(
                        child: Text("Hi modal sheet"),
                      )),
                ),
              ],
            ),
          ),
          Container(child: Icon(Icons.directions_transit)),
          Container(child: Icon(Icons.directions_bike)),
          Container(child: Icon(Icons.directions_bike)),
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
