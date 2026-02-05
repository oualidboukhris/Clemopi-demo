import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/layout/scan_doc_layout.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  String typeCard = "Student";
  bool isSelected = true;
  bool isTooglecard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Step 2 out of 3",
          style: TextStyle(
              color: Theme.of(context).primaryColorLight, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Select the type of ID",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isTooglecard == true) {
                        setState(() {
                          typeCard = "Student";
                          isTooglecard = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, right: 10),
                      decoration: BoxDecoration(
                        color: isTooglecard == true
                            ? const Color(0xFFEEEEEE)
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 1.5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            isTooglecard == true
                                ? "images/icons/icon-card-no-active.png"
                                : "images/icons/icon-card-active.png",
                            width: 180,
                          ),
                          CircleAvatar(
                            backgroundColor: const Color(0XFFE0E0E0),
                            child: Icon(
                              Icons.check,
                              color: isTooglecard == true
                                  ? const Color(0XFFE0E0E0)
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Text(
                              "Student card",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isTooglecard == false) {
                        setState(() {
                          typeCard = "Teacher";
                          isTooglecard = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, right: 10),
                      decoration: BoxDecoration(
                        color: isTooglecard == false
                            ? const Color(0xFFEEEEEE)
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 1.5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            isTooglecard == false
                                ? "images/icons/icon-card-no-active.png"
                                : "images/icons/icon-card-active.png",
                            width: 200,
                          ),
                          CircleAvatar(
                            backgroundColor: const Color(0XFFE0E0E0),
                            child: Icon(
                              Icons.check,
                              color: isTooglecard == false
                                  ? const Color(0XFFE0E0E0)
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Text(
                              "Teacher card",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_rounded,
                      color: Colors.white.withOpacity(0.8)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Informations that you share during the process of adding official documents is ruled by our confidentiality policy.",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () async {
                  await availableCameras().then((value) async => {
                        Navigator.push(context,
                            SlideRight(page: PageScanDoc(value, typeCard))),
                      });
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 85, vertical: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColor),
                    child: const Text(
                      "Take a picture of the document",
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
      )),
    );
  }
}
