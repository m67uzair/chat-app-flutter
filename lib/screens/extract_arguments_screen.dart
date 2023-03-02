import 'package:chat_app_flutter/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ExtractArgumentsScreen extends StatelessWidget {
  const ExtractArgumentsScreen({super.key});

  static const routeName = '/chatScreen';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final args = ModalRoute.of(context)!.settings.arguments as ChatScreen?;
    String? name = ModalRoute.of(context)!.settings.name;

    return Container(
      child: Center(child: Text(name ?? "pado ")),
    );
    //  ChatScreen(
    //     peerNickname: args.peerNickname,
    //     peerAvatar: args.peerAvatar,
    //     peerId: args.peerId,
    //     userAvatar: args.userAvatar);
  }
}
