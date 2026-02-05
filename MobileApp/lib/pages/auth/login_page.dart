// ignore: file_names
import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/pages/auth/forgot_password_page.dart';
import 'package:clemopi_app/pages/auth/register_page.dart';
import 'package:clemopi_app/services/api_service.dart';
import 'package:clemopi_app/services/api_config.dart';
import 'package:clemopi_app/services/user_service.dart';
import 'package:clemopi_app/pages/home_page.dart';
import 'package:clemopi_app/models/users.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<List<ConnectivityResult>>? subscription;
  bool isBarConnectivity = false;
  bool hasinternet = false;
  bool isloading = false;
  bool isObscure = true;
  final ApiService _api = ApiService();

  // Login with local MySQL backend API
  Future<void> loginIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isloading = true);

      // Trim whitespace from email and password
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      try {
        final response = await _api.post(
          ApiConfig.login,
          {
            'email': trimmedEmail,
            'password': trimmedPassword,
          },
          requiresAuth: false,
        );

        setState(() => isloading = false);

        // Check if request was successful (response is wrapped by ApiService)
        if (response['success'] == true) {
          // Login successful - save tokens and user data
          final data = response['data'];

          // Save the xsrfToken for future authenticated requests
          if (data['xsrfToken'] != null) {
            await _api.saveTokens(xsrfToken: data['xsrfToken']);
          }

          // Populate Users.userData for HomePage compatibility
          if (data['user'] != null) {
            final user = data['user'];
            Users.userData = {
              'userId': user['id']?.toString() ?? '',
              'displayName': user['username'] ??
                  '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
              'email': user['email'] ?? '',
              'phoneNumber': user['phoneNumber'] ?? '',
              'address': '',
              'cinNumber': '',
              'city': '',
              'birthday': '',
              'balance': int.tryParse(user['balance']?.toString() ?? '0') ?? 0,
              'unitePrice': 1,
              'secondsPrice': 60,
              'duration': 0,
              'timeOutReserve': 0,
              'photoUrl': '',
              'cardUrl': '',
              'typeCard': '',
              'inviteCode': '',
              'qrcodeBooked': false,
              'qrcodeScanned': false,
              'registerStatus': user['accountStatus'] ?? 'Active',
              'scooterReserved': '',
              'rides': [],
              'reserveCounter': {'counter': 0, 'dateTimeCounter': 0},
            };

            // Save the formatted user data to UserService for auto-login
            await UserService.saveUser(Users.userData);
          }

          if (!mounted) return;

          // Show success message
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: const Color(0xff4caf50),
            message: "Login successful!",
            icon: const Icon(
              Icons.check_circle,
              size: 28.0,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 2),
            leftBarIndicatorColor: const Color(0xff388e3c),
          ).show(context);

          // Navigate to home page
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
                context, SlideRight(page: const HomePage()), (route) => false);
          });
        } else {
          // Handle error from API
          final errorMsg =
              response['error'] ?? 'Login failed. Please try again.';
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
        setState(() => isloading = false);
        String errorMessage = 'Login failed. Please try again.';
        if (e.toString().contains('SocketException') ||
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
          print('Login error: $e');
        }
      }
    }
  }

  // Google Sign In - disabled for local database
  Future<void> signInWithGoogle() async {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: const Color(0xfff44336),
      message: "Google Sign In is not available with local database",
      icon: const Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      leftBarIndicatorColor: const Color(0xffba000d),
    ).show(context);
  }

  // Future<void> verifyPhone() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   await auth.verifyPhoneNumber(
  //     phoneNumber: '+212682076736',
  //     verificationFailed: (FirebaseAuthException e) {
  //       if (e.code == 'invalid-phone-number') {
  //         print('The provided phone number is not valid.');
  //       }

  //       // Handle other errors
  //     },
  //     verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //     codeSent: (String verificationId, int? forceResendingToken) {
  //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //           verificationId: verificationId, smsCode: "123658");
  //     },
  //   );
  // }

  Future<void> checkConnectivity() async {
    StreamSubscription<List<ConnectivityResult>> subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        hasinternet = !result.contains(ConnectivityResult.none);
      });

      final message = hasinternet
          ? "Vous êtes en ligne !"
          : "Vous êtes hors ligne! Vérifiez votre connexion Internet";
      final color = hasinternet ? Colors.green : Colors.red;
      final icon = hasinternet ? Icons.cloud_done : Icons.cloud_off;

      if (hasinternet == false) {
        Flushbar(
          isDismissible: false,
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: color,
          message: message,
          icon: Icon(
            icon,
            size: 28.0,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
          leftBarIndicatorColor: const Color(0xffba000d),
        ).show(context);
        setState(() {
          isBarConnectivity = true;
        });
      } else {
        if (isBarConnectivity == true) {
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: color,
            message: message,
            icon: Icon(
              icon,
              size: 28.0,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 3),
            leftBarIndicatorColor: const Color(0xff087f23),
          ).show(context);
        }
      }
    });
  }

  @override
  void initState() {
    checkConnectivity();
    // getToken();
    super.initState();
  }

  @override
  void dispose() {
    // subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg_02.png'), fit: BoxFit.cover)),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "Welcome to ",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 30),
                                  children: [
                                    TextSpan(
                                        text: 'CleMoPi',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 30,
                                            height: 1.5))
                                  ]),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Please login or register",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 110, 119, 80),
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 70.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(
                                color: Color.fromARGB(255, 125, 139, 78),
                                fontSize: 15,
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
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Password",
                              style: TextStyle(
                                color: Color.fromARGB(255, 125, 139, 78),
                                fontSize: 15,
                              ),
                            ),
                            TextFormField(
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                } else if (value.length < 4 &&
                                    value.length < 60) {
                                  return "Your password must contain between 4 and 60 characters.";
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Theme.of(context).primaryColor,
                              obscureText: isObscure ? true : false,
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isObscure = !isObscure;
                                    });
                                  },
                                  child: Icon(
                                    size: 28,
                                    isObscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.remove_red_eye_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
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
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: InkWell(
                          onTap: () => Navigator.push(context,
                              SlideRight(page: const ForgotPasswordPage())),
                          child: Text(
                            "Forgot your password?",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.9),
                                fontSize: 15),
                          ),
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
                            await loginIn(
                                emailController.text, passwordController.text);
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 85, vertical: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Theme.of(context).primaryColor),
                              child: isloading == false
                                  ? const Text(
                                      "Log In",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )
                                  : const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            "OU",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await signInWithGoogle();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "images/icons/google-icon.png",
                                  width: 25,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "Continue with google",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not a member yet?",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.9),
                                  fontSize: 15),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      SlideRight(page: const RegisterPage()));
                                },
                                child: Text(
                                  "Sign up!",
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
