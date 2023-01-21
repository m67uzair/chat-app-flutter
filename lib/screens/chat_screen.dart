import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
