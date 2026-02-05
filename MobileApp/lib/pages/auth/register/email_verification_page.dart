import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/pages/home_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  Timer? timer;

  Future checkVerifiedEmail() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      currentUser.emailVerified !=
          FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (currentUser.emailVerified) {
      timer?.cancel();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, SlideRight(page: const HomePage()), (route) => false);
    }
  }

  Future sendEmailVerified() async {
    if (!currentUser.emailVerified) {
      await currentUser.sendEmailVerification();
    }

    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkVerifiedEmail();
    });
  }

  @override
  void initState() {
    sendEmailVerified();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).primaryColorDark,
          title: const Text("Email Verification",
              style: TextStyle(color: Colors.white, fontSize: 19)),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.mail,
                    color: Theme.of(context).primaryColor,
                    size: 150,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Please check your email inbox if you don't receive email, check in spam",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
