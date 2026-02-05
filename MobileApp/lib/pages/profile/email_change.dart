import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/models/users.dart';
import 'package:clemopi_app/services/user_service.dart';
import '../auth/login_page.dart';

class EmailChangePage extends StatefulWidget {
  const EmailChangePage({Key? key}) : super(key: key);

  @override
  State<EmailChangePage> createState() => _EmailChangePageState();
}

class _EmailChangePageState extends State<EmailChangePage> {
  TextEditingController emailController = TextEditingController();
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';
  String get currentEmail => Users.userData['email']?.toString() ?? '';
  final _formKey = GlobalKey<FormState>();

  Future<void> signOut() async {
    // Clear local user data
    await UserService.clearUser();
    Users.userData = {};
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, SlideRight(page: const LoginPage()), (route) => false);
  }

  Future<void> updateEmail(email) async {
    if (_formKey.currentState!.validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                content: Row(
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child:
                          Text("Please wait", style: TextStyle(fontSize: 18)),
                    )
                  ],
                ),
              ),
            );
          });

      // TODO: Add API call to update email in MySQL
      // For now, just update local data
      setState(() {
        Users.userData["email"] = email;
        emailController.text = "";
      });

      if (!mounted) return;
      Navigator.pop(context);
      await Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: const Color(0xff4caf50),
        message: "Your update is successfully",
        icon: const Icon(
          Icons.check,
          size: 28.0,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 3),
        leftBarIndicatorColor: const Color(0xff087f23),
      ).show(context);
    }
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).primaryColorDark,
          title: const Text("Email Change",
              style: TextStyle(color: Colors.white, fontSize: 19)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Current address:",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      currentEmail,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Change your email address",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            final emailReg = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value!);
                            if (value.isEmpty) {
                              return "Please enter your email address";
                            } else if (!emailReg) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            hintText: "Please enter your email",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 201, 201, 201)),
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0XFFF1F1F1),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: InkWell(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        updateEmail(emailController.text);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 85, vertical: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).primaryColor),
                          child: const Text(
                            "Save",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
