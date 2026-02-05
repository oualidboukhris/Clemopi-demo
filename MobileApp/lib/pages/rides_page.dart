import 'package:flutter/material.dart';
import 'package:clemopi_app/models/users.dart';

import '../models/rides.dart';

class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColorDark,
            title: const Text("My rides")),
        body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Rides.myRides.isEmpty
                ? Center(
                    child: Text(
                    "You have no rides yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int index = 0;
                            index < Rides.myRides.length;
                            index++)
                          if (Rides.myRides[index]["sold"] != 0)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 12),
                                  child: Card(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  Rides.myRides[index]
                                                          ["dateTime"]
                                                      .toDate()
                                                      .toLocal()
                                                      .toString()
                                                      .split(" ")[0],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: ListTile(
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 0.0, right: 0.0),
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: 0,
                                                      vertical: -3),
                                              title: const Text("Rental time",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: Text(
                                                  Rides.myRides[index]
                                                          ["rentalTime"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.green,
                                                  )),
                                              trailing: Text(
                                                "${Rides.myRides[index]["sold"]} DH",
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                      ],
                    ),
                  )));
  }
}
