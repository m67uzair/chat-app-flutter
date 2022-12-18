import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final VoidCallback onClickedLogin;
  const Login({super.key, required this.onClickedLogin});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
