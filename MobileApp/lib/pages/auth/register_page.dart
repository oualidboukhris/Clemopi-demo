import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/pages/auth/login_page.dart';
import 'package:clemopi_app/services/api_service.dart';
import 'package:clemopi_app/services/api_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool ischecked = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isUserverified = false;
  bool isLoading = false;
  final ApiService _api = ApiService();

  // Register user with local MySQL backend API
  Future<void> register(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final response = await _api.post(
          ApiConfig.register,
          {
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'email': email,
            'password': password,
            'phone': phoneController.text.trim(),
          },
          requiresAuth: false,
        );

        setState(() => isLoading = false);

        // Check if the response was successful
        // The API wraps the backend response in 'data'
        final responseData = response['data'] ?? response;
        final isSuccess =
            response['success'] == true || (responseData['error'] == false);

        if (isSuccess) {
          // Registration successful - show success message and go to login
          if (!mounted) return;
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: const Color(0xff4caf50),
            message: 'Registration successful! Please log in.',
            icon: const Icon(
              Icons.check_circle,
              size: 28.0,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 3),
            leftBarIndicatorColor: const Color(0xff388e3c),
          ).show(context);

          // Navigate to login page after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
                context, SlideRight(page: const LoginPage()), (route) => false);
          });
        } else {
          // Handle error from API
          final errorMsg = response['error'] ??
              responseData['message'] ??
              'Registration failed. Please try again.';
          if (!mounted) return;
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: const Color(0xfff44336),
            message: errorMsg,
            icon: const Icon(
              Icons.warning,
              size: 28.0,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 3),
            leftBarIndicatorColor: const Color(0xffba000d),
          ).show(context);
        }
      } catch (e) {
        setState(() => isLoading = false);
        String errorMessage = 'Registration failed. Please try again.';
        if (e.toString().contains('User already exists')) {
          errorMessage = 'Email already in use. Please try again.';
        } else if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection')) {
          errorMessage =
              'Cannot connect to server. Please check your connection.';
        }
        if (!mounted) return;
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: const Color(0xfff44336),
          message: errorMessage,
          icon: const Icon(
            Icons.warning,
            size: 28.0,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
          leftBarIndicatorColor: const Color(0xffba000d),
        ).show(context);
        if (kDebugMode) {
          print('Registration error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
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
          backgroundColor: Theme.of(context).primaryColorDark,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          title: const Text("User Registration",
              style: TextStyle(color: Colors.white, fontSize: 19)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // First Name field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "First Name",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your first name";
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: "Please enter your first name",
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 201, 201, 201)),
                          filled: true,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          fillColor: const Color(0XFFF1F1F1),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                      )
                    ],
                  ),
                  // Last Name field
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Last Name",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your last name";
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: "Please enter your last name",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 201, 201, 201)),
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            fillColor: const Color(0XFFF1F1F1),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Phone field
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Phone Number",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your phone number";
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Please enter your phone number",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 201, 201, 201)),
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            fillColor: const Color(0XFFF1F1F1),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Email field
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Email",
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
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Please enter your email",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 201, 201, 201)),
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            fillColor: const Color(0XFFF1F1F1),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                        )
                      ],
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
                            "Passowrd",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            } else if (value.length < 4 && value.length < 60) {
                              return "Your password must contain between 4 and 60 characters.";
                            }
                            return null;
                          },
                          obscureText: true,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            hintText: "Please input your passowrd",
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
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Confirm password",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (passwordController.text != value) {
                              return "Your password and confirmation password do not match.";
                            }
                            return null;
                          },
                          obscureText: true,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            hintText: "Please confirm your password",
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
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith(
                              (states) => Theme.of(context).primaryColor,
                            ),
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -2),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: ischecked,
                            onChanged: (value) {
                              setState(() {
                                ischecked = value!;
                              });
                            }),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RichText(
                              text: TextSpan(
                                text: "i have read and i agree to ",
                                style: const TextStyle(
                                    color: Colors.white, height: 1.5),
                                children: [
                                  TextSpan(
                                      text:
                                          "CleMopi Terms and Conditions CleMopi privacy Policy.",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {})
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RichText(
                      text: TextSpan(
                        text:
                            "Information and recall on your rights regarding your personal data ",
                        style:
                            const TextStyle(color: Colors.white, height: 1.5),
                        children: [
                          TextSpan(
                              text: "Read more",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (kDebugMode) {
                                    print("oualid");
                                  }
                                })
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: ischecked == false
                          ? () => false
                          : () async {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              await register(emailController.text.trim(),
                                  passwordController.text.trim());
                            },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 85, vertical: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: ischecked == false
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)
                                  : Theme.of(context).primaryColor),
                          child: Text(
                            "Register",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ischecked == false
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Already registered?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 85, vertical: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).primaryColor),
                          child: const Text(
                            "Log in",
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
