import 'package:flutter/material.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/pages/home_page.dart';

class Step3 extends StatefulWidget {
  const Step3({super.key});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme:
                IconThemeData(color: Theme.of(context).primaryColorLight),
            backgroundColor: Theme.of(context).primaryColorDark,
            title: Text(
              "Step 3 out of 3",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 19),
            )),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Your documents were correctly\n Uploaded !",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        "Please visit our office to confirm your\n identity, and add some credit",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Image.asset(
                        'images/icons/1354347-localisation.png',
                        width: 350,
                        height: 350,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Lot 660, Hay Moulay Rachid Ben Guerir\n',
                          style: TextStyle(fontSize: 18),
                          children: [
                            TextSpan(
                                text: 'Mohammed VI Polytechnic University',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () async {
                          Navigator.pushAndRemoveUntil(
                              context,
                              SlideRight(page: const HomePage()),
                              (route) => false);
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 85, vertical: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).primaryColor),
                            child: const Text(
                              "Return to the app",
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
        ));
  }
}
