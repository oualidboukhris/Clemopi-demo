import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clemopi_app/pages/auth/login_page.dart';
import 'package:clemopi_app/pages/home_page.dart';
import 'package:clemopi_app/services/user_service.dart';
import 'package:clemopi_app/models/users.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => AutoLoginState();
}

class AutoLoginState extends State<AutoLogin> {
  bool isLoading = true;
  bool isLoggedIn = false;

  Future<void> checkCurrentuser() async {
    // Check local storage for saved user
    final isUserLoggedIn = await UserService.isLoggedIn();
    if (isUserLoggedIn) {
      // Load user data from local storage
      final userData = await UserService.getUser();
      if (userData != null) {
        Users.userData = userData;
        setState(() {
          isLoggedIn = true;
          isLoading = false;
        });
        return;
      }
    }
    setState(() {
      isLoggedIn = false;
      isLoading = false;
    });
  }

  @override
  void initState() {
    checkCurrentuser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (isLoggedIn) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
