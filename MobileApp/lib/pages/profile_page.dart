import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/models/users.dart';
import 'package:clemopi_app/pages/auth/forgot_password_page.dart';
import 'package:clemopi_app/pages/auth/register/step2.dart';
import 'package:clemopi_app/pages/profile/birthday_change.dart';
import 'package:clemopi_app/pages/profile/name_change.dart';
import 'package:clemopi_app/pages/profile/phone_change.dart';
import 'package:clemopi_app/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImagePicker imagePicker = ImagePicker();
  XFile? fileImage;
  // Use local UserService instead of FirebaseAuth
  final UserService _userService = UserService();
  String get currentUserId => Users.userData['userId']?.toString() ?? '';
  final firebaseStorage = FirebaseStorage.instance;
  String? downloaderUrl;
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

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
      // Récupérer le nom du fichier de manière sécurisée
      String fileName = fileImage!.name;

      var snapshot = await firebaseStorage
          .ref()
          .child("$currentUserId/$fileName")
          .putFile(File(fileImage!.path));
      downloaderUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        Users.userData["photoUrl"] = downloaderUrl;
      });

      final users = await usersCollection.get();
      for (var queryDocumentSnapshot in users.docs) {
        if (queryDocumentSnapshot.get("userId") == currentUserId) {
          usersCollection
              .doc(queryDocumentSnapshot.id)
              .update({"photoUrl": downloaderUrl});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).primaryColorDark,
          title: Text(
            "Personal details",
            style: TextStyle(
                color: Theme.of(context).primaryColorLight, fontSize: 18),
          )),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Users.userData["photoUrl"] == ""
                          ? CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              maxRadius: 50,
                              backgroundImage: const AssetImage(
                                "images/icons/photo-avatar-profil.png",
                              ))
                          : CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              maxRadius: 50,
                              backgroundImage: NetworkImage(
                                Users.userData["photoUrl"],
                              ),
                              child: Users.userData["photoUrl"] == ""
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 2,
                                    )
                                  : const Text("")),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: InkWell(
                          onTap: () async {
                            await uploadImage();
                            await storageImage();
                          },
                          child: Text(
                            "Change profile photo",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: InkWell(
                          onTap: () async {
                            // await Navigator.push(context,
                            //     SlideRight(page: const EmailChangePage()));
                            // setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "Account",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                              Expanded(
                                  child: Text(
                                Users.userData['email']?.toString() ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15),
                              )),
                              // Icon(
                              //   Icons.arrow_forward_ios_rounded,
                              //   color: Colors.white.withOpacity(0.5),
                              // )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(context,
                                SlideRight(page: const NameChangePage()));
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "Full name",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                              Expanded(
                                  child: Text(
                                Users.userData["displayName"],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15),
                              )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: InkWell(
                          onTap: () async {
                            Navigator.push(context,
                                SlideRight(page: const PhoneChangePage()));
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "Modify contact",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                              Expanded(
                                  child: Text(
                                Users.userData["phoneNumber"] == ""
                                    ? "None"
                                    : Users.userData["phoneNumber"],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15),
                              )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(context,
                                SlideRight(page: const BirthdayChangePage()));
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "Birthday",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              Expanded(
                                  child: Text(
                                Users.userData["birthday"] == ""
                                    ? "None"
                                    : Users.userData["birthday"],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15),
                              )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: InkWell(
                          onTap: Users.userData["registerStatus"] != "Invalid"
                              ? () => false
                              : () async {
                                  await Navigator.push(
                                      context, SlideRight(page: const Step2()));
                                  setState(() {});
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "User's document",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                              Users.userData["registerStatus"] == "Invalid"
                                  ? Expanded(
                                      child: Text(
                                      Users.userData["registerStatus"],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.red[400],
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ))
                                  : Expanded(
                                      child: Text(
                                      Users.userData["registerStatus"],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.green[400],
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context,
                                SlideRight(page: const ForgotPasswordPage()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text(
                                "Reset password",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                              Expanded(
                                  child: Text(
                                "Password",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15),
                              )),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: Colors.white.withOpacity(.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
