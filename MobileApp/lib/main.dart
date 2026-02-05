import 'package:clemopi_app/auto_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleMopi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Roboto',
          primaryColor: const Color(0XFFADC347),
          primaryColorLight: Colors.white,
          primaryColorDark: const Color(0XFF191A1A),
          scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31)),
      home: const AutoLogin(),
    );
  }
}
