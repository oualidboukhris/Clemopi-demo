import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/models/users.dart';

class NameChangePage extends StatefulWidget {
  const NameChangePage({Key? key}) : super(key: key);

  @override
  State<NameChangePage> createState() => _NameChangePageState();
}

class _NameChangePageState extends State<NameChangePage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';
  final _formKey = GlobalKey<FormState>();

  Future<void> save() async {
    if (_formKey.currentState!.validate()) {
      if (firstNameController.text ==
              Users.userData["displayName"].toString().split(" ")[0] &&
          lastNameController.text ==
              Users.userData["displayName"].toString().split(" ")[1]) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: const Color(0xfff44336),
          message: "Nothing has changed",
          icon: const Icon(
            Icons.warning,
            size: 28.0,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
          leftBarIndicatorColor: const Color(0xffba000d),
        ).show(context);
      } else {
        // Update local user data
        // TODO: Add API call to update user name in MySQL
        setState(() {
          Users.userData["displayName"] =
              "${firstNameController.text} ${lastNameController.text}";
        });
        if (!mounted) return;
        Flushbar(
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
  }

  Future<void> initialisationFullName() async {
    setState(() {
      firstNameController.text =
          Users.userData["displayName"].toString().split(" ")[0];
      lastNameController.text =
          Users.userData["displayName"].toString().split(" ")[1];
    });
  }

  @override
  void initState() {
    initialisationFullName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text("Full Name",
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
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
                          if (value!.isEmpty) {
                            return "Please enter your first name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                          if (value!.isEmpty) {
                            return "Please enter your last name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 85, vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).primaryColor),
                      child: InkWell(
                        onTap: () {
                          save();
                        },
                        child: const Text(
                          "Save",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
