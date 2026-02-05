import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:clemopi_app/models/users.dart';

class PhoneChangePage extends StatefulWidget {
  const PhoneChangePage({Key? key}) : super(key: key);
  @override
  State<PhoneChangePage> createState() => _PhoneChangePageState();
}

class _PhoneChangePageState extends State<PhoneChangePage> {
  String? phoneCountry;
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';
  TextEditingController phoneController = TextEditingController();

  Future<void> updatePhone(phoneNumber) async {
    if (phoneNumber == Users.userData["phoneNumber"]) {
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
      // TODO: Add API call to update phone in MySQL
      // For now, just update local data
      setState(() {
        Users.userData["phoneNumber"] = "$phoneNumber";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text("Phone Change",
            style: TextStyle(color: Colors.white, fontSize: 19)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
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
                    IntlPhoneField(
                      controller: phoneController,
                      initialValue: Users.userData["phoneNumber"],
                      decoration: InputDecoration(
                        hintText: 'Please enter your phone number',
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
                      initialCountryCode: 'MA',
                      onChanged: (phone) {
                        setState(() {
                          phoneCountry = phone.countryCode;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: InkWell(
                  onTap: () {
                    updatePhone("$phoneCountry ${phoneController.text}");
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
    );
  }
}
