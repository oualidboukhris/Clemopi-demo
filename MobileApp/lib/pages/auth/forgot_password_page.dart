import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword(email) async {
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

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        String message = "";
        if (e.code == 'user-not-found') {
          message = "No user found for that email.";
        } else {
          message = "An error occurred. Please try again.";
        }
        await Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.red,
          message: message,
          icon: const Icon(
            Icons.error,
            size: 28.0,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
          leftBarIndicatorColor: Colors.redAccent,
        ).show(context);
        return;
      }
      setState(() {
        emailController.clear();
      });
      if (!mounted) return;
      Navigator.pop(context);
      await Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: const Color(0xff4caf50),
        message: "Reset password email sent",
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
          appBar: AppBar(
            iconTheme:
                IconThemeData(color: Theme.of(context).primaryColorLight),
            backgroundColor: Theme.of(context).primaryColorDark,
            title: const Text("Reset Password",
                style: TextStyle(color: Colors.white, fontSize: 19)),
          ),
          body: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/bg_02.png'),
                      fit: BoxFit.cover)),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Receive an email to reset your password",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    height: 1.5),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text(
                                "Email",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 125, 139, 78),
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
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Theme.of(context).primaryColor,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 110, 119, 80))),
                                fillColor: Theme.of(context).primaryColor,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: InkWell(
                                onTap: () async {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  resetPassword(emailController.text);
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 85, vertical: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Theme.of(context).primaryColor),
                                    child: const Text(
                                      "Reset password",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
              ))),
    );
  }
}
