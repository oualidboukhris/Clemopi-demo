import 'package:flutter/material.dart';

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColorDark,
            iconTheme:
                IconThemeData(color: Theme.of(context).primaryColorLight),
            title: Text(
              "Add Credit",
              style: TextStyle(color: Colors.white, fontSize: 19),
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
                      "Please visit our office to add\nsome credit",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
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
                          style: TextStyle(fontSize: 17),
                          children: [
                            TextSpan(
                                text: 'Mohammed VI Polytechnic University',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
