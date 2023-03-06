import 'package:chat_app_flutter/firebase_options.dart';
import 'package:chat_app_flutter/providers/auth_provider.dart';
import 'package:chat_app_flutter/providers/chat_provider.dart';
import 'package:chat_app_flutter/providers/home_provider.dart';
import 'package:chat_app_flutter/providers/profile_provider.dart';
import 'package:chat_app_flutter/screens/extract_arguments_screen.dart';
import 'package:chat_app_flutter/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    prefs: prefs,
  ));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.prefs}) : super(key: key);

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final SharedPreferences prefs;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) =>
              AuthProvider(firebaseAuth: FirebaseAuth.instance, firebaseFirestore: firebaseFirestore, prefs: prefs),
        ),
        Provider<HomeProvider>(
          create: (_) => HomeProvider(firebaseFirestore: firebaseFirestore),
        ),
        Provider<ProfileProvider>(
          create: (_) =>
              ProfileProvider(prefs: prefs, firebaseStorage: firebaseStorage, firebaseFirestore: firebaseFirestore),
        ),
        Provider<ChatProvider>(
          create: (_) =>
              ChatProvider(prefs: prefs, firebaseStorage: firebaseStorage, firebaseFirestore: firebaseFirestore),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xff1E1E1E),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {

              return  HomeScreen(currentUserId: snapshot.data?.uid,);
            } else {
              return const AuthPage();
            }
          },
        ),
      ),
    );
  }
}
