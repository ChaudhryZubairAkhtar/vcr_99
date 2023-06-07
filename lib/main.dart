import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_classroom/views/homepage.dart';
import 'package:my_classroom/views/signin_page.dart';
import 'package:my_classroom/views/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: './',
    routes: {'./': (context) => MainPage()},
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return SigninPage();
          }
        });
  }
}
