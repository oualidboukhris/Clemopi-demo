import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/models/users.dart';
import 'package:clemopi_app/pages/auth/register/step2.dart';

class Step1 extends StatefulWidget {
  const Step1({Key? key}) : super(key: key);

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firebaseStorage = FirebaseStorage.instance;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");
  String? firstName;
  String? lastName;
  String? displayName;
  String? email;
  String? phoneNumber;
  String? address;
  String? city;
  String? birthday;
  String? photoUrl;
  String? cardUrl;
  String? inviteCode;
  bool qrcodeBooked = false;
  bool qrcodeScanned = false;
  String registerStatus = "Invalid";
  XFile? fileImage;
  ImagePicker imagePicker = ImagePicker();
  String? downloaderUrl;
  String? phoneCountry;
  final _formKey = GlobalKey<FormState>();
  bool isvalidate = false;

  Future<void> uploadImage() async {
    try {
      final XFile? fileImageUpload =
          await imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        fileImage = fileImageUpload;
      });
    } catch (e) {
      if (kDebugMode) {
        print('error ImgePicker: $e');
      }
    }
  }

  Future<void> storageImage() async {
    if (fileImage != null) {
      var snapshot = await firebaseStorage
          .ref()
          .child("${currentUser.uid}/${fileImage!.name.split("r")[1]}")
          .putFile(File(fileImage!.path));
      downloaderUrl = await snapshot.ref.getDownloadURL();
      photoUrl = downloaderUrl;
    }
  }

  Future<void> continueTostep2() async {
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
      await storageImage();
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      displayName = "$firstName $lastName";
      email = currentUser.email;
      phoneNumber = "$phoneCountry ${phoneNumberController.text}";
      address = addressController.text;
      city = cityController.text;
      birthday = birthDayController.text;
      cardUrl = ""; // await
      inviteCode = ""; //await
      bool qrcodeBooked = false;
      bool qrcodeScanned = false;
      currentUser.updateDisplayName(displayName);
      currentUser.updatePhotoURL(photoUrl);
      await usersCollection.add(Users(
          currentUser.uid,
          displayName!,
          email!,
          phoneNumber!,
          address!,
          "",
          city!,
          birthday!,
          0,
          0,
          0,
          0,
          0,
          {"counter": 0, "dateTimeCounter": 0},
          photoUrl == null ? "" : photoUrl!,
          cardUrl!,
          "",
          inviteCode!,
          qrcodeBooked,
          qrcodeScanned,
          registerStatus,
          "",
          []).toJson());

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context, SlideRight(page: const Step2()), (route) => false);
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
          title: const Text("Step 1 out of 3",
              style: TextStyle(color: Colors.white, fontSize: 19)),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              fileImage == null
                                  ? const CircleAvatar(
                                      radius: 45.0,
                                      backgroundImage: AssetImage(
                                          "images/icons/photo-avatar-profil.png"))
                                  : CircleAvatar(
                                      radius: 45.0,
                                      backgroundColor: Colors.black,
                                      backgroundImage:
                                          FileImage(File(fileImage!.path))),
                              InkWell(
                                onTap: () async {
                                  await uploadImage();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 5),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                          focusedErrorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
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
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                          "Phone Number",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IntlPhoneField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
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
                          focusedErrorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                          errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        initialCountryCode: 'MA',
                        onChanged: (phone) {
                          phoneCountry = phone.countryCode;
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Birthday",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextFormField(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            initialDatePickerMode: DatePickerMode.day,
                            builder: (context, child) {
                              return Theme(
                                  data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                          primary:
                                              Theme.of(context).primaryColor)),
                                  child: child!);
                            },
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100));

                        if (pickedDate != null) {
                          setState(() {
                            birthDayController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                      controller: birthDayController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your birthday";
                        }
                        return null;
                      },
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.calendar_month_rounded,
                          size: 25,
                          color: Theme.of(context).primaryColor,
                        ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "address",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: addressController,
                        keyboardType: TextInputType.streetAddress,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "City",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: cityController,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
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
                  padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                  child: InkWell(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      continueTostep2();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 85, vertical: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Theme.of(context).primaryColor),
                        child: const Text(
                          "Continue",
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
        )),
      ),
    );
  }
}
