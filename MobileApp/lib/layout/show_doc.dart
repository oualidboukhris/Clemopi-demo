import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/layout/scan_doc_layout.dart';
import 'package:clemopi_app/pages/auth/register/step3.dart';
import 'package:clemopi_app/models/users.dart';

// ignore: must_be_immutable
class ShowDoc extends StatefulWidget {
  String imageUrl;
  String typeCard;

  ShowDoc(this.imageUrl, this.typeCard, {super.key});

  @override
  State<ShowDoc> createState() => _ShowDocState();
}

class _ShowDocState extends State<ShowDoc> {
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';

  XFile? fileImage;
  String? downloaderUrl;
  bool isvalidate = false;

  Future<void> storageImage() async {
    // TODO: Implement image upload to local server/storage
    // For now, skip Firebase storage
    print("Image storage skipped - needs local implementation");
  }

  Future<void> uploadData() async {
    // TODO: Implement API call to update user data in MySQL
    // For now, just store locally
    await storageImage();
    Users.userData["registerStatus"] = "En cours...";
    Users.userData["typeCard"] = widget.typeCard;
  }

  @override
  void initState() {
    //-------------- initialisation Picture card ------------//
    fileImage = XFile(widget.imageUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).primaryColorDark,
          title: const Text("Verify Document"),
          actions: [
            IconButton(
                onPressed: () async {
                  await availableCameras().then((value) => {
                        Navigator.pushReplacement(
                            context,
                            SlideRight(
                                page: PageScanDoc(value, widget.typeCard)))
                      });
                },
                icon: const Icon(
                  Icons.refresh,
                )),
            IconButton(
                onPressed: () async {
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
                                  child: Text("Please wait",
                                      style: TextStyle(fontSize: 18)),
                                )
                              ],
                            ),
                          ),
                        );
                      });

                  await uploadData();
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context,
                      SlideRight(page: const Step3()), (route) => false);
                },
                icon: const Icon(Icons.check)),
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.file(File(widget.imageUrl), fit: BoxFit.cover),
        ));
  }
}
