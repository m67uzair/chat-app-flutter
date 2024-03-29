import 'package:chat_app_flutter/providers/auth_provider.dart';
import 'package:chat_app_flutter/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  final VoidCallback onClickedRegister;

  const Login({super.key, required this.onClickedRegister});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.contain,
                  width: size.width,
                  height: size.height / 3,
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 22.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Login',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CustomTextFormField(
                            hintText: "Email",
                            icon: const Icon(Icons.alternate_email),
                            controller: emailController,
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Email is required"),
                              EmailValidator(errorText: "please enter a valid email address")
                            ]),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CustomTextFormField(
                            controller: passwordController,
                            hintText: "Password",
                            icon: const Icon(Icons.lock_outline_rounded),
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Password is required"),
                              MinLengthValidator(6, errorText: "Password Must be at-least 6 characters")
                            ]),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Forgot Password?",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.indigo.shade900),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {

                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              await authProvider.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                              print("handle sign in started");
                              await authProvider.handleSignIn();
                              print("handle sign in stoped");
                              authProvider.setSignInActivity = true;

                              navigatorKey.currentState!.popUntil((route) => route.isFirst);
                            }

                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: const Text("Login"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(
                                text: "New here? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextSpan(
                                text: "Register!",
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()..onTap = widget.onClickedRegister,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
