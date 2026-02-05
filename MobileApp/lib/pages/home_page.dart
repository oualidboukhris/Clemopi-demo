// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:based_battery_indicator/based_battery_indicator.dart';
// import 'package:battery_indicator/battery_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/models/rides.dart';
import 'package:clemopi_app/models/scooters.dart';
import 'package:clemopi_app/models/stations.dart';
import 'package:clemopi_app/models/users.dart';
import 'package:clemopi_app/pages/auth/login_page.dart';
import 'package:clemopi_app/pages/auth/register/step2.dart';
import 'package:clemopi_app/pages/credit_page.dart';
import 'package:clemopi_app/pages/profile_page.dart';
import 'package:clemopi_app/pages/rides_page.dart';
import 'package:clemopi_app/services/user_service.dart';
import 'package:clemopi_app/services/api_service.dart';
import 'package:clemopi_app/services/scooter_service.dart';
import 'package:clemopi_app/pages/qr_scan_unlock_example.dart';
import 'package:clemopi_app/pages/qr_scan_page.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:smart_timer/smart_timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Duration durationTimer = const Duration();
  SmartTimer? countTimer;
  int reduceSecondsBy = 0;
  int stateCounterReserve = 0;
  bool lockReserved = false;
  // Use local user data instead of FirebaseAuth
  String get currentUserId => Users.userData['userId']?.toString() ?? '';
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");
  CollectionReference scootersCollection =
      FirebaseFirestore.instance.collection("scooters");
  CollectionReference stationsCollection =
      FirebaseFirestore.instance.collection("Stations");
  final GlobalKey qrKey = GlobalKey();
  bool serviceEnabled = false;
  bool locationEnabled = false;
  bool isBarShowing = false;
  bool isBarConnectivity = false;
  bool isCheck = false;
  bool isBlocked = true;
  bool hasinternet = true;
  late GoogleMapController mapController;
  late PermissionStatus permessionGranted;
  Location location = Location();
  Barcode? result;
  QRViewController? qrController;
  String? scooterId;
  StreamSubscription? streamMaps;
  StreamSubscription? streamConnectivity;
  StreamSubscription? streamRider;
  StreamSubscription? streamStation;
  List myRides = [];
  PersistentBottomSheetController? controllerBotomSheet1;
  PersistentBottomSheetController? controllerBotomSheet2;
  GlobalKey<ScaffoldState> keyScaffold = GlobalKey();

  // Scooter service for lock/unlock
  final ScooterService _scooterService = ScooterService();

  //----------------------------  User --------------------------//
  Future<void> getDataUser() async {
    // Skip Firebase call if user data is already loaded from local login
    if (Users.userData.isNotEmpty) {
      return;
    }
    // For now, just return - we'll use data set during login
    // Firebase Firestore calls removed to prevent hanging
    return;
  }

  Future<void> initilisationData(idScooter) async {
    final snapshotUser = await usersCollection.get();
    final snapshotScooter = await scootersCollection.get();
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        usersCollection.doc(queryDocumentSnapshot.id).update({
          "qrcodeScanned": false,
          "qrcodeBooked": false,
          "scooterReserved": ""
        });
        for (var queryDocumentSnapshotScooter in snapshotScooter.docs) {
          if (queryDocumentSnapshotScooter.get("id") == idScooter) {
            scootersCollection
                .doc(queryDocumentSnapshotScooter.id)
                .update({"isScanned": false, "isReserved": false, "rider": ""});
          }
        }
      }
    }
  }

  //---------------------------- Station --------------------------//
  Future<void> getDatastations() async {
    // Firebase Firestore calls removed to prevent hanging
    // TODO: Implement local API call for stations if needed
    setState(() {
      Stations.stationsData.clear();
      // Add mock station data for testing
      Stations.stationsData.addAll([
        {
          'id': '01',
          'name': 'Station 1',
          'lat': '33.5731',
          'lang': '-7.5898',
        },
      ]);
    });
    return;
  }

  //------------------------- Scooters ---------------------------
  // Future<void> addScooters() async {
  //   await scootersCollection.doc("QR850005").set(Scooter(
  //       "Station01", "15", "driveStatus", "faultCode", "16", "", "120", true).toJson());
  //   await scootersCollection.doc("QR856275").set(Scooter(
  //       "Station02", "19", "driveStatus", "faultCode", "188", "", "12", false).toJson());
  //   await scootersCollection.doc("QR792545").set(Scooter(
  //       "Station03", "50", "driveStatus", "faultCode", "18", "", "15", false).toJson());
  // }
  Future<void> getDataScooters(String idStation) async {
    setState(() {
      Scooter.scootersData.clear();
    });
    final snapshot = await scootersCollection.get();
    for (var queryDocumentSnapshot in snapshot.docs) {
      if (queryDocumentSnapshot.get("station") == "Station$idStation") {
        setState(() {
          Scooter.scootersData
              .addAll([queryDocumentSnapshot.data() as Map<String, dynamic>]);
        });
      }
    }
  }

  Future<void> getDataScooter(String idScooter) async {
    final snapshotUser = await usersCollection.get();
    final snapshotScooter = await scootersCollection.get();
    for (var queryDocumentSnapshotUsers in snapshotUser.docs) {
      if (queryDocumentSnapshotUsers.get("userId") == currentUserId) {
        for (var queryDocumentSnapshotScooter in snapshotScooter.docs) {
          if (queryDocumentSnapshotScooter.get("id") == idScooter) {
            setState(() {
              Scooter.scooterData =
                  queryDocumentSnapshotScooter.data() as Map<String, dynamic>;
            });
          }
        }
      }
    }
  }

  Future<void> reservedScotter(
      String idScooter, bool isReserved, StateSetter setStateSetter) async {
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
                    child: Text("Please wait", style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
          );
        });
    final snapshotUser = await usersCollection.get();
    final snapshotScooter = await scootersCollection.get();
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        if (isReserved == true) {
          await usersCollection.doc(queryDocumentSnapshot.id).update({
            "qrcodeScanned": false,
            "qrcodeBooked": true,
            "scooterReserved": idScooter
          });
        } else {
          await usersCollection.doc(queryDocumentSnapshot.id).update({
            "qrcodeScanned": false,
            "qrcodeBooked": false,
            "scooterReserved": ""
          });
        }
      }
    }
    for (var queryDocumentSnapshot in snapshotScooter.docs) {
      if (queryDocumentSnapshot.get("id") == idScooter) {
        if (isReserved == true) {
          await scootersCollection.doc(queryDocumentSnapshot.id).update({
            "isReserved": true,
            "rider": Users.userData["userId"],
            "isScanned": false
          });
        } else {
          await scootersCollection
              .doc(queryDocumentSnapshot.id)
              .update({"isReserved": false, "rider": ""});
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> reservedCounter(bool isResreved, setStateSetter) async {
    final snapshotUser = await usersCollection.get();
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        final reserveCounter = queryDocumentSnapshot.get("reserveCounter");
        if (isResreved == true) {
          switch (reserveCounter["counter"]) {
            case 0:
              await streamReserved(Scooter.scooterData["id"], setStateSetter,
                  Scooter.scooterData["rider"], true, 1);
              break;
            case 1:
              final durationTimer =
                  Timestamp.now().seconds - reserveCounter["dateTimeCounter"];
              if (durationTimer < stateCounterReserve) {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Please wait 20 seconds and retry",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    });
              } else {
                setState(() {
                  stateCounterReserve = 0;
                });
                await streamReserved(Scooter.scooterData["id"], setStateSetter,
                    Scooter.scooterData["rider"], true, 1);
              }
              break;
            case 2:
              final durationTimer =
                  Timestamp.now().seconds - reserveCounter["dateTimeCounter"];
              if (durationTimer < stateCounterReserve) {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "Please wait 15 minutes and try again",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ))
                            ],
                          )),
                        ),
                      );
                    });
              } else {
                setState(() {
                  stateCounterReserve = 0;
                });
                await streamReserved(Scooter.scooterData["id"], setStateSetter,
                    Scooter.scooterData["rider"], true, 1);
              }
              break;

            case 3:
              final durationTimer =
                  Timestamp.now().seconds - reserveCounter["dateTimeCounter"];
              if (durationTimer < stateCounterReserve) {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Please wait 15 minutes and try again",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    });
              } else {
                setState(() {
                  stateCounterReserve = 0;
                });
                await streamReserved(Scooter.scooterData["id"], setStateSetter,
                    Scooter.scooterData["rider"], true, 1);
              }
              break;
            case 4:
              final durationTimer =
                  Timestamp.now().seconds - reserveCounter["dateTimeCounter"];
              if (durationTimer < stateCounterReserve) {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Please wait 24 hours and try again",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    });
              } else {
                Map<String, dynamic> counter = {
                  "counter": 0,
                  "dateTimeCounter": 0,
                };
                await usersCollection
                    .doc(queryDocumentSnapshot.id)
                    .update({"reserveCounter": counter});
                setState(() {
                  stateCounterReserve = 0;
                });
                await streamReserved(Scooter.scooterData["id"], setStateSetter,
                    Scooter.scooterData["rider"], true, 1);
              }
              break;
            default:
          }
        } else {
          switch (reserveCounter["counter"]) {
            case 0:
              setState(() {
                stateCounterReserve = 20;
                lockReserved = true;
              });
              Map<String, dynamic> counter = {
                "counter": 1,
                "dateTimeCounter": Timestamp.now().seconds,
              };
              await usersCollection
                  .doc(queryDocumentSnapshot.id)
                  .update({"reserveCounter": counter});
              await streamReserved(Scooter.scooterData["id"], setStateSetter,
                  Scooter.scooterData["rider"], false, 1);
              break;
            case 1:
              setState(() {
                stateCounterReserve = 900;
                lockReserved = true;
              });
              Map<String, dynamic> counter = {
                "counter": 2,
                "dateTimeCounter": Timestamp.now().seconds,
              };
              await usersCollection
                  .doc(queryDocumentSnapshot.id)
                  .update({"reserveCounter": counter});
              await streamReserved(Scooter.scooterData["id"], setStateSetter,
                  Scooter.scooterData["rider"], false, 1);
              break;
            case 2:
              setState(() {
                stateCounterReserve = 900;
                lockReserved = true;
              });
              Map<String, dynamic> counter = {
                "counter": 3,
                "dateTimeCounter": Timestamp.now().seconds,
              };
              usersCollection
                  .doc(queryDocumentSnapshot.id)
                  .update({"reserveCounter": counter});
              await streamReserved(Scooter.scooterData["id"], setStateSetter,
                  Scooter.scooterData["rider"], false, 1);
              break;
            case 3:
              setState(() {
                stateCounterReserve = 86400;
                lockReserved = true;
              });
              Map<String, dynamic> counter = {
                "counter": 4,
                "dateTimeCounter": Timestamp.now().seconds,
              };
              usersCollection
                  .doc(queryDocumentSnapshot.id)
                  .update({"reserveCounter": counter});
              await streamReserved(Scooter.scooterData["id"], setStateSetter,
                  Scooter.scooterData["rider"], false, 1);
              break;
            default:
          }
        }
      }
    }
  }

  //----------------------- update State scooter --------------------------//

  Future<void> updateData(String idScooter) async {
    final snapshotUser = await usersCollection.get();
    final snapshotScooter = await scootersCollection.get();
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        usersCollection.doc(queryDocumentSnapshot.id).update({
          "qrcodeScanned": true,
          "qrcodeBooked": false,
          "scooterReserved": ""
        });
      }
    }
    for (var queryDocumentSnapshot in snapshotScooter.docs) {
      if (queryDocumentSnapshot.get("id") == idScooter) {
        scootersCollection.doc(queryDocumentSnapshot.id).update({
          "rider": Users.userData["userId"],
          "isScanned": true,
          "isReserved": false
        });
      }
    }
  }

  Future<void> updateState(String idScooter) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Scooter$idScooter");
    final snapshotUser = await usersCollection.get();
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        await ref
            .update({"data/state": 1, "data/rider": queryDocumentSnapshot.id});
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    await Future.delayed(const Duration(seconds: 5));
    for (var queryDocumentSnapshot in snapshotUser.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        final snapshot = await ref.child('data/unlocked').get();
        if (snapshot.value == 1) {
          streamJourney(idScooter, setState, queryDocumentSnapshot.id);
          await updateData(idScooter);
        } else {
          await ref.update({"data/state": 0, "data/rider": ""});
          await showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Theme.of(context).primaryColorDark,
                  ),
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.amber[400],
                          size: 200,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            "The scooter is damaged.",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      ],
                    )),
                  ),
                );
              });
        }
      }
    }
  }

  //------------------------------ Stream ---------------------------------//

  Future<void> streamJourney(
      String idScooter, StateSetter stateSetter, String idRider) async {
    DatabaseReference refData =
        FirebaseDatabase.instance.ref("Scooter$idScooter/data");
    streamStation = refData.onValue.listen((event) async {
      final refState = event.snapshot.child("state").value;
      final refRider = event.snapshot.child("rider").value;

      if (refRider != idRider && refState == 0) {
        if (!mounted) return;
        stateSetter(() {
          isBlocked = false;
          isBarShowing = false;
        });
        await initilisationData(idScooter);
        await decreaseSold("scanned");
        await getDataUser();
        await getDataRides();
        streamStation!.cancel();
      } else if (refState == 1) {
        if (!mounted) return;
        stateSetter(() {
          isBlocked = true;
          isBarShowing = true;
        });
      }
    });
  }

  Future<void> streamReserved(String idScooter, StateSetter setStateSetter,
      String idRider, bool isReserved, int stateResreve) async {
    DatabaseReference refState =
        FirebaseDatabase.instance.ref("Scooter$idScooter/data/state");
    DatabaseReference refData =
        FirebaseDatabase.instance.ref("Scooter$idScooter/data");

    if (stateResreve == 1 && isReserved == true) {
      final snapshotUser = await usersCollection.get();
      for (var queryDocumentSnapshot in snapshotUser.docs) {
        if (queryDocumentSnapshot.get("userId") == currentUserId) {
          streamRider = refState.onValue.listen((event) async {
            if (stateResreve == 1 && isReserved == true) {
              streamRider?.pause();
              await refData
                  .update({"state": 2, "rider": queryDocumentSnapshot.id});
              await reservedScotter(idScooter, isReserved, setStateSetter);
              stateResreve = 0;
              setStateSetter(() {
                Scooter.scooterData["isReserved"] = true;
                Scooter.scooterData["rider"] = Users.userData["userId"];
              });
              streamRider?.resume();
            } else if (stateResreve == 0 &&
                event.snapshot.value == 0 &&
                Scooter.scooterData["rider"] == Users.userData["userId"]) {
              await decreaseSold("reserved");
              if (!mounted) return;
              final popNavigator = Navigator.canPop(context);
              if (popNavigator) {
                Navigator.pop(context);
                await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Reservation time has expired",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    });
              } else {
                await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.amber[400],
                                size: 200,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Reservation time has expired",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              )
                            ],
                          )),
                        ),
                      );
                    });
              }
              streamRider!.cancel();
            }
          });
        }
      }
    } else if (stateResreve == 1 && isReserved == false) {
      streamRider?.pause();
      await refData.update({"state": 0, "rider": ""});
      await reservedScotter(idScooter, isReserved, setStateSetter);
      setStateSetter(() {
        Scooter.scooterData["isReserved"] = false;
        Scooter.scooterData["rider"] = "";
      });
      streamRider?.cancel();
    }
  }

  //-------------------------------- Map ---------------------------------//
  // Future<void> setMarkerCustomImage() async {
  //   markers.clear();
  //   markers.add(
  //      Marker(
  //     markerId: const MarkerId("Station 1"),
  //     position:const  LatLng(33.983221943158235, -6.869083307683468),
  //     onTap: (){
  //         print("************************************oualid");
  //     },
  //     // icon: await BitmapDescriptor.fromAssetImage(
  //     //     const ImageConfiguration(size: Size(5, 5)), 'images/icons/618981.png'),
  //   ));
  //   setState(() {
  //   });
  // }
  //------------------------Current location ---------------------
  Future<void> getCurrentlocation(bool tooglePosition) async {
    final permissionStatus = await location.hasPermission();
    final serviceEnabled = await location.serviceEnabled();

    if (permissionStatus != PermissionStatus.granted) {
      await location.requestPermission();
    } else if (serviceEnabled == false) {
      await location.requestService();
    } else {
      try {
        if (tooglePosition == false) {
          setState(() {
            locationEnabled = true;
          });

          streamMaps = location.onLocationChanged.listen((loactionData) async {
            await mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(loactionData.latitude!, loactionData.longitude!),
                zoom: 17.0,
              ),
            ));
          });
        } else {
          streamMaps?.cancel();
          setState(() {
            locationEnabled = false;
          });
        }
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print(e.code);
        }
      }
    }
  }

  //---------------------------- My rides --------------------------//
  Future<void> getDataRides() async {
    // Firebase Firestore calls removed to prevent hanging
    // TODO: Implement local API call for rides if needed
    Rides.myRides.clear();
    return;
  }

  Future<void> rides(int sold, int duration) async {
    Duration rentalTime = Duration(seconds: duration);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(rentalTime.inHours.remainder(60));
    final minutes = twoDigits(rentalTime.inMinutes.remainder(60));
    final seconds = twoDigits(rentalTime.inSeconds.remainder(60));
    final snapshot = await usersCollection.get();
    for (var queryDocumentSnapshot in snapshot.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        Map<String, dynamic> rides = {
          "sold": sold,
          "dateTime": Timestamp.fromDate(DateTime.now()),
          "rentalTime": "$hours:$minutes:$seconds"
        };
        await usersCollection.doc(queryDocumentSnapshot.id).update({
          "rides": FieldValue.arrayUnion([rides])
        });
      }
    }
    myRides.clear();
  }

  //---------------------------- Decrease Sold --------------------------//
  Future<void> decreaseSold(type) async {
    final snapshot = await usersCollection.get();
    int resultSold;
    for (var queryDocumentSnapshot in snapshot.docs) {
      if (queryDocumentSnapshot.get("userId") == currentUserId) {
        int balance = queryDocumentSnapshot.get("balance") as int;
        int duration = queryDocumentSnapshot.get("duration") as int;
        int unitePrice = queryDocumentSnapshot.get("unitePrice") as int;
        int secondsPrice = queryDocumentSnapshot.get("secondsPrice") as int;
        int timeOutReserve = queryDocumentSnapshot.get("timeOutReserve") as int;
        if (type == "scanned") {
          resultSold = (balance - (duration ~/ secondsPrice * unitePrice));
          await rides(resultSold - balance, duration);
          await usersCollection
              .doc(queryDocumentSnapshot.id)
              .update({"balance": resultSold, "duration": 0});
        } else if (type == "reserved") {
          resultSold =
              (balance - (timeOutReserve ~/ secondsPrice * unitePrice));
          await rides(resultSold - balance, duration);
          await usersCollection
              .doc(queryDocumentSnapshot.id)
              .update({"balance": resultSold, "timeOutReserve": 0});
        }
      }
    }
  }

  //---------------------------- Sign out --------------------------//
  Future<void> signOut() async {
    // Clear local user data and tokens
    await UserService.clearUser();
    Users.userData = {};
    await ApiService().clearToken();

    // Also try to sign out from Google if used previously
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      // Ignore errors - user may not have used Google sign in
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, SlideRight(page: const LoginPage()), (route) => false);
  }

//---------------------------- Connectivity --------------------------//
  Future<void> checkConnectivity() async {
    StreamSubscription<List<ConnectivityResult>> subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        setState(() {
          hasinternet = false;
        });
      } else {
        setState(() {
          hasinternet = true;
        });
      }
    });

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        hasinternet = false;
      });
    } else {
      setState(() {
        hasinternet = true;
      });
    }
  }

  Future<void> showDialogConnection(ConnectivityResult result) async {
    bool isShowingdialog = Navigator.canPop(context);
    if (isShowingdialog == true) {
      Navigator.pop(context);
    }
    setState(() {
      hasinternet = result != ConnectivityResult.none;
    });
    final message = hasinternet
        ? "You're back online!"
        : "You're offline! Check your internet connection.";
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
        duration: const Duration(seconds: 2),
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
          duration: const Duration(seconds: 2),
          leftBarIndicatorColor: const Color(0xff087f23),
        ).show(context);
      }
    }
  }

  Future<void> showModalBottom(scooterId) async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSetter) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Theme.of(context).primaryColorDark,
              ),
              height: MediaQuery.of(context).size.height / 2,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 14.0, right: 14, top: 14),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 17),
                              decoration: BoxDecoration(
                                color: const Color(0XFF353535),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const Text("Remaining\n Distance",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      "${Scooter.scooterData["remainingDistance"]} Km",
                                      style: const TextStyle(
                                          color: Color(0XFFFFC90E),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 32),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0XFF353535),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("${Scooter.scooterData["battery"]} %",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: BasedBatteryIndicator(
                                      status: BasedBatteryStatus(
                                        value: Scooter.scooterData["battery"],
                                        type: BasedBatteryStatusType.normal,
                                      ),
                                      trackHeight: 12.0,
                                      trackAspectRatio: 3.0,
                                      curve: Curves.ease,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Center(
                            child: Image.asset(
                                "images/icons/scooter-qr-code-icon.png",
                                width: 280)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          streamRider?.cancel();
                          await getDataScooter(scooterId);
                          if (!mounted) return;
                          if ((Scooter.scooterData["isReserved"] == true &&
                                  Scooter.scooterData['rider'] !=
                                      Users.userData["userId"]) ||
                              Scooter.scooterData["isScanned"] == true) {
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30)),
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: Center(
                                      child: SingleChildScrollView(
                                          child: Column(
                                        children: [
                                          Icon(
                                            Icons.warning_rounded,
                                            color: Colors.amber[400],
                                            size: 200,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 20.0),
                                            child: Text(
                                              "This scooter is taken!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 15.0),
                                            child: Text(
                                              "Look for another one",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          )
                                        ],
                                      )),
                                    ),
                                  );
                                });
                          } else {
                            Navigator.pop(context);
                            await showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30)),
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            QRView(
                                              key: qrKey,
                                              onQRViewCreated: (QRViewController
                                                  controller) {
                                                controller.resumeCamera();
                                                qrController = controller;
                                                controller.scannedDataStream
                                                    .listen((scanData) async {
                                                  if (scanData.code != "") {
                                                    if (scanData.code ==
                                                                Scooter.scooterData[
                                                                    "qrCode"] &&
                                                            Scooter.scooterData[
                                                                    'rider'] ==
                                                                Users.userData[
                                                                    "userId"] ||
                                                        Scooter.scooterData[
                                                                'rider'] ==
                                                            "") {
                                                      qrController!.dispose();
                                                      getDataScooter(scooterId);
                                                      await updateState(
                                                          scooterId);
                                                    } else {
                                                      qrController!.dispose();
                                                      await showModalBottomSheet(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          builder: (context) {
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            30),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            30)),
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2,
                                                              child: Center(
                                                                child:
                                                                    SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .warning_rounded,
                                                                      color: Colors
                                                                              .amber[
                                                                          400],
                                                                      size: 200,
                                                                    ),
                                                                    const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 20.0),
                                                                      child:
                                                                          Text(
                                                                        "This scooter is taken!",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 18),
                                                                      ),
                                                                    ),
                                                                    const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 15.0),
                                                                      child:
                                                                          Text(
                                                                        "Look for another one",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 18),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )),
                                                              ),
                                                            );
                                                          });
                                                      qrController!
                                                          .resumeCamera();
                                                    }
                                                  }
                                                });
                                              },
                                              overlay: QrScannerOverlayShape(
                                                overlayColor: Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(.8),
                                                borderColor: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: 10,
                                                borderLength: 30,
                                                borderWidth: 3,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0, right: 15),
                                              child: InkWell(
                                                  onTap: () async {
                                                    await qrController
                                                        ?.toggleFlash();
                                                  },
                                                  child: Image.asset(
                                                      'images/icons/flashlight.png',
                                                      width: 50)),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                .whenComplete(() async => await getDataUser());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 11, bottom: 11, left: 24, right: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).primaryColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock_open_rounded,
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Unlock",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: InkWell(
                          onTap: () async {
                            await getDataScooter(Scooter.scooterData["id"]);
                            if (!mounted) return;
                            if ((Scooter.scooterData["isReserved"] == true &&
                                    Scooter.scooterData["rider"] !=
                                        Users.userData["userId"]) ||
                                Scooter.scooterData["isScanned"] == true) {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30)),
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      child: Center(
                                        child: SingleChildScrollView(
                                            child: Column(
                                          children: [
                                            Icon(
                                              Icons.warning_rounded,
                                              color: Colors.amber[400],
                                              size: 200,
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0),
                                              child: Text(
                                                "This scooter is taken!",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 15.0),
                                              child: Text(
                                                "Look for another one",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                    );
                                  });
                            } else {
                              if (Scooter.scooterData["isReserved"] == false) {
                                await reservedCounter(true, setStateSetter);
                              } else {
                                await reservedCounter(false, setStateSetter);
                                // await streamReserved(
                                //     Scooter.scooterData["id"],
                                //     setStateSetter,
                                //     Scooter.scooterData["rider"],
                                //     false,
                                //     1);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 11, bottom: 15, left: 22, right: 28),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).primaryColor),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    (Scooter.scooterData["isReserved"] ==
                                                    false &&
                                                Scooter.scooterData["rider"] !=
                                                    Users.userData["userId"]) ||
                                            Scooter.scooterData["isScanned"] ==
                                                true
                                        ? "Reserve"
                                        : "Annuler reserve",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )),
            );
          });
        }).whenComplete(() {
      getDataUser();
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    getDataUser().then((value) => {
          if (Users.userData["duration"] != 0)
            {decreaseSold("scanned"), getDataRides()},
          if (Users.userData["timeOutReserve"] != 0)
            {decreaseSold("reserved"), getDataRides()}
        });
    getDatastations();
    getDataRides();
    //setMarkerCustomImage();

    //------------------------service Status Stream ---------------------
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        if (!mounted) return;
        setState(() {
          locationEnabled = false;
        });
      }
    });
  }

  // Scooter info data from QR scan
  Map<String, dynamic>? _scannedScooterInfo;
  bool _isLoadingScooterInfo = false;

  // Show scooter info bottom sheet with lock/unlock options
  void _showScooterInfoBottomSheet(BuildContext context) {
    // Reset scooter info when opening
    _scannedScooterInfo = null;
    _isLoadingScooterInfo = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 15),
              // Title
              Text(
                'Scooter Controls',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              const SizedBox(height: 15),
              // Scan QR Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: _isLoadingScooterInfo
                      ? null
                      : () async {
                          // Open QR scanner
                          final qrResult = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRScanPage(),
                            ),
                          );

                          if (qrResult != null && qrResult.isNotEmpty) {
                            setModalState(() {
                              _isLoadingScooterInfo = true;
                            });

                            // Get scooter info
                            final result = await _scooterService
                                .getScooterInfoByQR(qrResult);

                            setModalState(() {
                              _isLoadingScooterInfo = false;
                              if (result['error'] != true &&
                                  result['scooter'] != null) {
                                _scannedScooterInfo = result['scooter'];
                              } else {
                                _scannedScooterInfo = null;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ??
                                        'Failed to get scooter info'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                        },
                  icon: _isLoadingScooterInfo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner, size: 24),
                  label: Text(
                    _isLoadingScooterInfo ? 'Loading...' : 'Scan QR Code',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Scooter Info Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _scannedScooterInfo == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.electric_scooter,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Scan QR code to get scooter details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // QR Code
                              _buildInfoRow(
                                icon: Icons.qr_code,
                                label: 'QR Code',
                                value: _scannedScooterInfo!['qrCode']
                                        ?.toString() ??
                                    'N/A',
                                color: Theme.of(context).primaryColor,
                              ),
                              const Divider(color: Colors.grey),
                              // Battery
                              _buildInfoRow(
                                icon: Icons.battery_charging_full,
                                label: 'Battery',
                                value:
                                    '${_scannedScooterInfo!['battery'] ?? 'N/A'}%',
                                color: Colors.green,
                              ),
                              const Divider(color: Colors.grey),
                              // Lock State
                              _buildInfoRow(
                                icon:
                                    _scannedScooterInfo!['lock_state'] == 'true'
                                        ? Icons.lock
                                        : Icons.lock_open,
                                label: 'Lock State',
                                value:
                                    _scannedScooterInfo!['lock_state'] == 'true'
                                        ? 'Locked'
                                        : 'Unlocked',
                                color:
                                    _scannedScooterInfo!['lock_state'] == 'true'
                                        ? Colors.red
                                        : Colors.green,
                              ),
                              const Divider(color: Colors.grey),
                              // Speed
                              _buildInfoRow(
                                icon: Icons.speed,
                                label: 'Speed',
                                value:
                                    '${_scannedScooterInfo!['speed'] ?? '0'} km/h',
                                color: Colors.blue,
                              ),
                              const Divider(color: Colors.grey),
                              // Region
                              _buildInfoRow(
                                icon: Icons.location_on,
                                label: 'Region',
                                value: _scannedScooterInfo!['region']
                                        ?.toString() ??
                                    'N/A',
                                color: Colors.orange,
                              ),
                              const Divider(color: Colors.grey),
                              // Total Distance
                              _buildInfoRow(
                                icon: Icons.straighten,
                                label: 'Total Distance',
                                value:
                                    '${_scannedScooterInfo!['total_meters'] ?? '0'} m',
                                color: Colors.purple,
                              ),
                              const Divider(color: Colors.grey),
                              // Total Minutes
                              _buildInfoRow(
                                icon: Icons.timer,
                                label: 'Total Time',
                                value:
                                    '${_scannedScooterInfo!['total_minutes'] ?? '0'} min',
                                color: Colors.teal,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              // Lock/Unlock Buttons (only show if scooter info is loaded)
              if (_scannedScooterInfo != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Unlock scooter
                            final result =
                                await _scooterService.unlockScooterByQR(
                                    _scannedScooterInfo!['qrCode']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Unlocked'),
                                backgroundColor: result['error'] == true
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_open, size: 20),
                          label: const Text('Unlock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Lock scooter
                            final result =
                                await _scooterService.lockScooterByQR(
                                    _scannedScooterInfo!['qrCode']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Locked'),
                                backgroundColor: result['error'] == true
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock, size: 20),
                          label: const Text('Lock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for info rows
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    streamRider?.cancel();
    streamConnectivity?.cancel();
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hasinternet == false
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("images/bg_02.png"),
            )),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 140,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Vous êtes hors ligne! Vérifiez votre connexion Internet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Users.userData.isEmpty
            ? Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icon/icon.png",
                        width: 130,
                        height: 130,
                      ),
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 2,
                      )
                    ],
                  ),
                ),
              )
            : Scaffold(
                floatingActionButton: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Scooter info button
                    FloatingActionButton(
                      heroTag: "scooterBtn",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _showScooterInfoBottomSheet(context);
                      },
                      child: Icon(
                        Icons.electric_scooter,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // GPS location button
                    FloatingActionButton(
                      heroTag: "locationBtn",
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        await getCurrentlocation(locationEnabled);
                      },
                      child: Icon(Icons.my_location_rounded,
                          color: locationEnabled == false
                              ? const Color(0XFF666666)
                              : Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  iconTheme:
                      IconThemeData(color: Theme.of(context).primaryColorLight),
                  title: Center(
                    child: Image.asset("images/logo.png", width: 110),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => false,
                      icon: const Icon(
                        color: Colors.grey,
                        Icons.newspaper_rounded,
                        size: 25,
                      ),
                    )
                  ],
                ),
                drawer: Drawer(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  child: ListView(
                    children: [
                      DrawerHeader(
                          margin: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Users.userData["photoUrl"] == "" ||
                                          Users.userData["photoUrl"] == null
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          width: 75,
                                          height: 75,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.asset(
                                              "images/icons/photo-avatar-profil.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ))
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          width: 75,
                                          height: 75,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                              Users.userData["photoUrl"],
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                );
                                              },
                                            ),
                                          )),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, left: 8.0),
                                            child: Text(
                                              Users.userData["displayName"]
                                                      ?.toString() ??
                                                  'User',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                Users.userData["balance"] !=
                                                            null &&
                                                        Users.userData[
                                                                "balance"] !=
                                                            ""
                                                    ? "${Users.userData["balance"]} DH"
                                                    : "",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            SlideRight(
                                                page: const CreditPage()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 26, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Add credit",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              onTap: () async {
                                await Navigator.push(context,
                                    SlideRight(page: const ProfilePage()));
                                setState(() {});
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Profile",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            ListTile(
                              onTap: () async {
                                await Navigator.push(context,
                                    SlideRight(page: const RidesPage()));
                                setState(() {});
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("My rides",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.map_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            ListTile(
                              onTap: () async {
                                await Navigator.push(context,
                                    SlideRight(page: const QRScanUnlockPage()));
                                setState(() {});
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Scan QR Code",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.qr_code_scanner,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            ListTile(
                              onTap: () async {},
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Invites friends",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.person_add,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                            ListTile(
                              onTap: () => false,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Help",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.help,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                            ListTile(
                              onTap: () => false,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("FAQs",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.live_help_rounded,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                            ListTile(
                              onTap: () => false,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                              title: const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Legal",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 17)),
                              ),
                              leading: const Icon(
                                Icons.error_outlined,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15),
                        child: Divider(
                          height: 2,
                          color: Colors.white.withOpacity(.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 55.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                signOut();
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 26, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Theme.of(context).primaryColor),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 15.0),
                                        child: Icon(Icons.logout_rounded),
                                      ),
                                      Text(
                                        "Sign Out",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    GoogleMap(
                      markers: <Marker>{
                        for (int i = 0; i < Stations.stationsData.length; i++)
                          Marker(
                              markerId: MarkerId(
                                  "Station ${Stations.stationsData[i]["id"]}"),
                              icon: BitmapDescriptor.defaultMarkerWithHue(84),
                              position: LatLng(
                                  double.parse(Stations.stationsData[i]["lat"]),
                                  double.parse(
                                      Stations.stationsData[i]["lang"])),
                              onTap: false
                                  ? () => false
                                  : () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return WillPopScope(
                                              onWillPop: () async => false,
                                              child: AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                backgroundColor: Colors.white,
                                                content: Row(
                                                  children: [
                                                    CircularProgressIndicator(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      strokeWidth: 2,
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20.0),
                                                      child: Text("Please wait",
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                      await getDataUser();
                                      await getDataScooter(
                                          Users.userData["scooterReserved"]);
                                      if (Users.userData["balance"] <= 0) {
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                        await showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  30),
                                                          topRight:
                                                              Radius.circular(
                                                                  30)),
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2,
                                                child: Center(
                                                  child: SingleChildScrollView(
                                                      child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.warning_rounded,
                                                        color:
                                                            Colors.amber[400],
                                                        size: 200,
                                                      ),
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 20.0),
                                                        child: Text(
                                                          "You need to add some credit to you wallet",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                                ),
                                              );
                                            });
                                      } else if (Users
                                                  .userData["qrcodeScanned"] ==
                                              true ||
                                          isBarShowing == true) {
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                        await showModalBottomSheet(
                                            enableDrag: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      StateSetter
                                                          setStateSetter) {
                                                return WillPopScope(
                                                  onWillPop: (() async =>
                                                      false),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(30),
                                                              topRight: Radius
                                                                  .circular(
                                                                      30)),
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    child: Center(
                                                        child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      12.0),
                                                          child: Text(
                                                            "Your ride is ongoing",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          "images/icons/scooter-icon.png",
                                                          width: 220,
                                                        ),
                                                      ],
                                                    )),
                                                  ),
                                                );
                                              });
                                            }).whenComplete(() => getDataUser());
                                      } else if ((Users
                                                  .userData["qrcodeBooked"] ==
                                              true &&
                                          Scooter.scooterData["rider"] ==
                                              Users.userData["userId"])) {
                                        await getDataScooter(
                                            Users.userData["scooterReserved"]);
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                        // await showModalBottomSheet(
                                        //     backgroundColor: Colors.transparent,
                                        //     context: context,
                                        //     builder: (context) {
                                        //       return StatefulBuilder(builder:
                                        //           (BuildContext context,
                                        //               StateSetter
                                        //                   setStateSetter) {
                                        //         return Container(
                                        //           clipBehavior: Clip.hardEdge,
                                        //           decoration: BoxDecoration(
                                        //             borderRadius:
                                        //                 const BorderRadius.only(
                                        //                     topLeft:
                                        //                         Radius.circular(
                                        //                             30),
                                        //                     topRight:
                                        //                         Radius.circular(
                                        //                             30)),
                                        //             color: Theme.of(context)
                                        //                 .primaryColorDark,
                                        //           ),
                                        //           height: MediaQuery.of(context)
                                        //                   .size
                                        //                   .height /
                                        //               2,
                                        //           child: SingleChildScrollView(
                                        //               child: Column(
                                        //             children: [
                                        //               Padding(
                                        //                 padding:
                                        //                     const EdgeInsets
                                        //                             .only(
                                        //                         left: 14.0,
                                        //                         right: 14,
                                        //                         top: 14),
                                        //                 child: Stack(
                                        //                   children: [
                                        //                     Row(
                                        //                       crossAxisAlignment:
                                        //                           CrossAxisAlignment
                                        //                               .start,
                                        //                       mainAxisAlignment:
                                        //                           MainAxisAlignment
                                        //                               .spaceBetween,
                                        //                       children: [
                                        //                         Container(
                                        //                           clipBehavior:
                                        //                               Clip.hardEdge,
                                        //                           padding: const EdgeInsets
                                        //                                   .symmetric(
                                        //                               horizontal:
                                        //                                   6,
                                        //                               vertical:
                                        //                                   17),
                                        //                           decoration:
                                        //                               BoxDecoration(
                                        //                             color: const Color(
                                        //                                 0XFF353535),
                                        //                             borderRadius:
                                        //                                 BorderRadius.circular(
                                        //                                     10),
                                        //                           ),
                                        //                           child: Column(
                                        //                             children: [
                                        //                               const Text(
                                        //                                   "Remaining\n Distance",
                                        //                                   textAlign: TextAlign
                                        //                                       .center,
                                        //                                   style:
                                        //                                       TextStyle(
                                        //                                     fontSize:
                                        //                                         16,
                                        //                                     color:
                                        //                                         Colors.white,
                                        //                                   )),
                                        //                               Padding(
                                        //                                 padding:
                                        //                                     const EdgeInsets.only(top: 12.0),
                                        //                                 child:
                                        //                                     Text(
                                        //                                   "${Scooter.scooterData["remainingDistance"]} Km",
                                        //                                   style: const TextStyle(
                                        //                                       color: Color(0XFFFFC90E),
                                        //                                       fontSize: 22,
                                        //                                       fontWeight: FontWeight.bold),
                                        //                                 ),
                                        //                               )
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Container(
                                        //                           padding: const EdgeInsets
                                        //                                   .symmetric(
                                        //                               horizontal:
                                        //                                   24,
                                        //                               vertical:
                                        //                                   32),
                                        //                           decoration:
                                        //                               BoxDecoration(
                                        //                             borderRadius:
                                        //                                 BorderRadius.circular(
                                        //                                     10),
                                        //                             color: const Color(
                                        //                                 0XFF353535),
                                        //                           ),
                                        //                           child: Column(
                                        //                             children: [
                                        //                               Text(
                                        //                                   " ${Scooter.scooterData["battery"]}%",
                                        //                                   textAlign: TextAlign
                                        //                                       .center,
                                        //                                   style:
                                        //                                       const TextStyle(
                                        //                                     fontSize:
                                        //                                         20,
                                        //                                     fontWeight:
                                        //                                         FontWeight.bold,
                                        //                                     color:
                                        //                                         Colors.white,
                                        //                                   )),
                                        //                               Padding(
                                        //                                 padding:
                                        //                                     const EdgeInsets.only(top: 12.0),
                                        //                                 child:
                                        //                                     BatteryIndicator(
                                        //                                   batteryFromPhone:
                                        //                                       false,
                                        //                                   batteryLevel:
                                        //                                       Scooter.scooterData["battery"],
                                        //                                   style:
                                        //                                       BatteryIndicatorStyle.skeumorphism,
                                        //                                   colorful:
                                        //                                       true,
                                        //                                   showPercentNum:
                                        //                                       false,
                                        //                                   mainColor:
                                        //                                       Theme.of(context).primaryColor,
                                        //                                   size:
                                        //                                       13,
                                        //                                   ratio:
                                        //                                       3,
                                        //                                 ),
                                        //                               )
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                       ],
                                        //                     ),
                                        //                     Center(
                                        //                         child: Image.asset(
                                        //                             "images/icons/scooter-qr-code-icon.png",
                                        //                             width:
                                        //                                 280)),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //               Column(
                                        //                 children: [
                                        //                   InkWell(
                                        //                     onTap: () async {
                                        //                       await getDataScooter(
                                        //                           Scooter.scooterData[
                                        //                               "id"]);
                                        //                       if (!mounted) {
                                        //                         return;
                                        //                       }
                                        //                       if (Scooter.scooterData[
                                        //                                   "isReserved"] ==
                                        //                               true &&
                                        //                           Scooter.scooterData[
                                        //                                   "rider"] !=
                                        //                               Users.userData[
                                        //                                   "userId"]) {
                                        //                         showModalBottomSheet(
                                        //                             backgroundColor:
                                        //                                 Colors
                                        //                                     .transparent,
                                        //                             context:
                                        //                                 context,
                                        //                             builder:
                                        //                                 (context) {
                                        //                               return Container(
                                        //                                 decoration:
                                        //                                     BoxDecoration(
                                        //                                   borderRadius: const BorderRadius.only(
                                        //                                       topLeft: Radius.circular(30),
                                        //                                       topRight: Radius.circular(30)),
                                        //                                   color:
                                        //                                       Theme.of(context).primaryColorDark,
                                        //                                 ),
                                        //                                 height:
                                        //                                     MediaQuery.of(context).size.height /
                                        //                                         2,
                                        //                                 child:
                                        //                                     Center(
                                        //                                   child: SingleChildScrollView(
                                        //                                       child: Column(
                                        //                                     children: [
                                        //                                       Icon(
                                        //                                         Icons.warning_rounded,
                                        //                                         color: Colors.amber[400],
                                        //                                         size: 200,
                                        //                                       ),
                                        //                                       const Padding(
                                        //                                         padding: EdgeInsets.only(top: 20.0),
                                        //                                         child: Text(
                                        //                                           "This scooter is taken!",
                                        //                                           style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                         ),
                                        //                                       ),
                                        //                                       const Padding(
                                        //                                         padding: EdgeInsets.only(top: 15.0),
                                        //                                         child: Text(
                                        //                                           "Look for another one",
                                        //                                           style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                         ),
                                        //                                       )
                                        //                                     ],
                                        //                                   )),
                                        //                                 ),
                                        //                               );
                                        //                             });
                                        //                       } else {
                                        //                         Navigator.pop(
                                        //                             context);
                                        //                         await showModalBottomSheet(
                                        //                                 context:
                                        //                                     context,
                                        //                                 builder:
                                        //                                     (context) {
                                        //                                   return Container(
                                        //                                     decoration:
                                        //                                         const BoxDecoration(
                                        //                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                        //                                     ),
                                        //                                     height:
                                        //                                         MediaQuery.of(context).size.height / 2,
                                        //                                     child:
                                        //                                         Stack(
                                        //                                       alignment: Alignment.topRight,
                                        //                                       children: [
                                        //                                         QRView(
                                        //                                           key: qrKey,
                                        //                                           onQRViewCreated: (QRViewController controller) {
                                        //                                             controller.resumeCamera();
                                        //                                             qrController = controller;
                                        //                                             controller.scannedDataStream.listen((scanData) async {
                                        //                                               if (scanData.code != "") {
                                        //                                                 if (scanData.code == Scooter.scooterData["qrCode"] && Scooter.scooterData["rider"] == Users.userData["userId"] || Scooter.scooterData["rider"] == "") {
                                        //                                                   qrController!.dispose();
                                        //                                                   await updateState(Scooter.scooterData["id"]);
                                        //                                                 } else {
                                        //                                                   qrController!.dispose();
                                        //                                                   showModalBottomSheet(
                                        //                                                       backgroundColor: Colors.transparent,
                                        //                                                       context: context,
                                        //                                                       builder: (context) {
                                        //                                                         return Container(
                                        //                                                           decoration: BoxDecoration(
                                        //                                                             borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                        //                                                             color: Theme.of(context).primaryColorDark,
                                        //                                                           ),
                                        //                                                           height: MediaQuery.of(context).size.height / 2,
                                        //                                                           child: Center(
                                        //                                                             child: SingleChildScrollView(
                                        //                                                                 child: Column(
                                        //                                                               children: [
                                        //                                                                 Icon(
                                        //                                                                   Icons.warning_rounded,
                                        //                                                                   color: Colors.amber[400],
                                        //                                                                   size: 200,
                                        //                                                                 ),
                                        //                                                                 const Padding(
                                        //                                                                   padding: EdgeInsets.only(top: 20.0),
                                        //                                                                   child: Text(
                                        //                                                                     "This scooter is taken!",
                                        //                                                                     style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                                                   ),
                                        //                                                                 ),
                                        //                                                                 const Padding(
                                        //                                                                   padding: EdgeInsets.only(top: 15.0),
                                        //                                                                   child: Text(
                                        //                                                                     "Look for another one",
                                        //                                                                     style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                                                   ),
                                        //                                                                 )
                                        //                                                               ],
                                        //                                                             )),
                                        //                                                           ),
                                        //                                                         );
                                        //                                                       });
                                        //                                                 }
                                        //                                               }
                                        //                                             });
                                        //                                           },
                                        //                                           overlay: QrScannerOverlayShape(
                                        //                                             overlayColor: Theme.of(context).backgroundColor.withOpacity(.8),
                                        //                                             borderColor: Theme.of(context).primaryColor,
                                        //                                             borderRadius: 10,
                                        //                                             borderLength: 30,
                                        //                                             borderWidth: 3,
                                        //                                           ),
                                        //                                         ),
                                        //                                         Padding(
                                        //                                           padding: const EdgeInsets.only(top: 20.0, right: 15),
                                        //                                           child: InkWell(
                                        //                                               onTap: () async {
                                        //                                                 await qrController?.toggleFlash();
                                        //                                               },
                                        //                                               child: Image.asset('images/icons/flashlight.png', width: 50)),
                                        //                                         ),
                                        //                                       ],
                                        //                                     ),
                                        //                                   );
                                        //                                 })
                                        //                             .whenComplete(
                                        //                                 () async =>
                                        //                                     await getDataUser());
                                        //                       }
                                        //                     },
                                        //                     child: Container(
                                        //                       padding:
                                        //                           const EdgeInsets
                                        //                                   .only(
                                        //                               top: 11,
                                        //                               bottom:
                                        //                                   11,
                                        //                               left: 24,
                                        //                               right:
                                        //                                   30),
                                        //                       decoration: BoxDecoration(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(
                                        //                                       50),
                                        //                           color: Theme.of(
                                        //                                   context)
                                        //                               .primaryColor),
                                        //                       child: Row(
                                        //                         mainAxisSize:
                                        //                             MainAxisSize
                                        //                                 .min,
                                        //                         children: [
                                        //                           const Icon(
                                        //                             Icons
                                        //                                 .lock_open_rounded,
                                        //                             size: 30,
                                        //                           ),
                                        //                           Padding(
                                        //                             padding: const EdgeInsets
                                        //                                     .only(
                                        //                                 left:
                                        //                                     8.0),
                                        //                             child: Text(
                                        //                               "Unlock",
                                        //                               style:
                                        //                                   TextStyle(
                                        //                                 color: Theme.of(context)
                                        //                                     .backgroundColor,
                                        //                                 fontSize:
                                        //                                     18,
                                        //                                 fontWeight:
                                        //                                     FontWeight.bold,
                                        //                               ),
                                        //                             ),
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                   ),
                                        //                   Padding(
                                        //                     padding:
                                        //                         const EdgeInsets
                                        //                                 .only(
                                        //                             top: 12.0),
                                        //                     child: InkWell(
                                        //                       onTap: () async {
                                        //                         await getDataScooter(
                                        //                             Scooter.scooterData[
                                        //                                 "id"]);
                                        //                         if (!mounted) {
                                        //                           return;
                                        //                         }
                                        //                         if ((Scooter.scooterData["isReserved"] ==
                                        //                                     true &&
                                        //                                 Scooter.scooterData["rider"] !=
                                        //                                     Users.userData[
                                        //                                         "userId"]) ||
                                        //                             Scooter.scooterData[
                                        //                                     "isScanned"] ==
                                        //                                 true) {
                                        //                           showModalBottomSheet(
                                        //                               backgroundColor:
                                        //                                   Colors
                                        //                                       .transparent,
                                        //                               context:
                                        //                                   context,
                                        //                               builder:
                                        //                                   (context) {
                                        //                                 return Container(
                                        //                                   decoration:
                                        //                                       BoxDecoration(
                                        //                                     borderRadius:
                                        //                                         const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                        //                                     color:
                                        //                                         Theme.of(context).primaryColorDark,
                                        //                                   ),
                                        //                                   height:
                                        //                                       MediaQuery.of(context).size.height / 2,
                                        //                                   child:
                                        //                                       Center(
                                        //                                     child: SingleChildScrollView(
                                        //                                         child: Column(
                                        //                                       children: [
                                        //                                         Icon(
                                        //                                           Icons.warning_rounded,
                                        //                                           color: Colors.amber[400],
                                        //                                           size: 200,
                                        //                                         ),
                                        //                                         const Padding(
                                        //                                           padding: EdgeInsets.only(top: 20.0),
                                        //                                           child: Text(
                                        //                                             "This scooter is taken!",
                                        //                                             style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                           ),
                                        //                                         ),
                                        //                                         const Padding(
                                        //                                           padding: EdgeInsets.only(top: 15.0),
                                        //                                           child: Text(
                                        //                                             "Look for another one",
                                        //                                             style: TextStyle(color: Colors.white, fontSize: 18),
                                        //                                           ),
                                        //                                         )
                                        //                                       ],
                                        //                                     )),
                                        //                                   ),
                                        //                                 );
                                        //                               });
                                        //                         } else {
                                        //                           if (Scooter.scooterData[
                                        //                                   "isReserved"] ==
                                        //                               false) {
                                        //                             await streamReserved(
                                        //                                 Scooter.scooterData[
                                        //                                     "id"],
                                        //                                 setStateSetter,
                                        //                                 Scooter.scooterData[
                                        //                                     "rider"],
                                        //                                 true,
                                        //                                 1);
                                        //                           } else {
                                        //                             await streamReserved(
                                        //                                 Scooter.scooterData[
                                        //                                     "id"],
                                        //                                 setStateSetter,
                                        //                                 Scooter.scooterData[
                                        //                                     "rider"],
                                        //                                 false,
                                        //                                 1);
                                        //                           }
                                        //                         }
                                        //                       },
                                        //                       child: Container(
                                        //                         padding:
                                        //                             const EdgeInsets
                                        //                                     .only(
                                        //                                 top: 11,
                                        //                                 bottom:
                                        //                                     15,
                                        //                                 left:
                                        //                                     22,
                                        //                                 right:
                                        //                                     28),
                                        //                         decoration: BoxDecoration(
                                        //                             borderRadius:
                                        //                                 BorderRadius.circular(
                                        //                                     50),
                                        //                             color: Theme.of(
                                        //                                     context)
                                        //                                 .primaryColor),
                                        //                         child: Row(
                                        //                           mainAxisSize:
                                        //                               MainAxisSize
                                        //                                   .min,
                                        //                           children: [
                                        //                             const Icon(
                                        //                               Icons
                                        //                                   .calendar_month_rounded,
                                        //                               size: 30,
                                        //                             ),
                                        //                             Padding(
                                        //                               padding: const EdgeInsets
                                        //                                       .only(
                                        //                                   left:
                                        //                                       8.0),
                                        //                               child:
                                        //                                   Text(
                                        //                                 (Scooter.scooterData["isReserved"] == false && Scooter.scooterData["rider"] != Users.userData["userId"]) ||
                                        //                                         Scooter.scooterData["isScanned"] == true
                                        //                                     ? "Reserve"
                                        //                                     : "Annuler reserve",
                                        //                                 style:
                                        //                                     TextStyle(
                                        //                                   color:
                                        //                                       Theme.of(context).backgroundColor,
                                        //                                   fontSize:
                                        //                                       18,
                                        //                                   fontWeight:
                                        //                                       FontWeight.bold,
                                        //                                 ),
                                        //                               ),
                                        //                             ),
                                        //                           ],
                                        //                         ),
                                        //                       ),
                                        //                     ),
                                        //                   )
                                        //                 ],
                                        //               )
                                        //             ],
                                        //           )),
                                        //         );
                                        //       });
                                        //     }).whenComplete(() => getDataUser());
                                        showModalBottom(
                                          Scooter.scooterData["id"],
                                        );
                                      } else {
                                        await getDataScooters(
                                            Stations.stationsData[i]["id"]);
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                        showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(builder:
                                                  (context,
                                                      StateSetter
                                                          setStateSetter) {
                                                return Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(30),
                                                              topRight: Radius
                                                                  .circular(
                                                                      30)),
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    child: Scooter.scootersData
                                                            .isEmpty
                                                        ? Center(
                                                            child: Text(
                                                              "No scooters available",
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          )
                                                        : ListView.builder(
                                                            itemCount: Scooter
                                                                .scootersData
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            12.0),
                                                                    child:
                                                                        InkWell(
                                                                      onTap: (Scooter.scootersData[index]["battery"] < 30) ||
                                                                              (Scooter.scootersData[index]["isReserved"] ==
                                                                                  true) ||
                                                                              (Scooter.scootersData[index]["rider"] !=
                                                                                  "")
                                                                          ? () =>
                                                                              false
                                                                          : () async {
                                                                              await getDataScooter(Scooter.scootersData[index]["id"]);
                                                                              if (!mounted) {
                                                                                return;
                                                                              }
                                                                              Navigator.pop(context);
                                                                              // showModalBottomSheet(
                                                                              //     backgroundColor: Colors.transparent,
                                                                              //     context: context,
                                                                              //     builder: (context) {
                                                                              //       return StatefulBuilder(builder: (BuildContext context, StateSetter setStateSetter) {
                                                                              //         return Container(
                                                                              //           clipBehavior: Clip.hardEdge,
                                                                              //           decoration: BoxDecoration(
                                                                              //             borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                                              //             color: Theme.of(context).primaryColorDark,
                                                                              //           ),
                                                                              //           height: MediaQuery.of(context).size.height / 2,
                                                                              //           child: SingleChildScrollView(
                                                                              //               child: Column(
                                                                              //             children: [
                                                                              //               Padding(
                                                                              //                 padding: const EdgeInsets.only(left: 14.0, right: 14, top: 14),
                                                                              //                 child: Stack(
                                                                              //                   children: [
                                                                              //                     Row(
                                                                              //                       crossAxisAlignment: CrossAxisAlignment.start,
                                                                              //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              //                       children: [
                                                                              //                         Container(
                                                                              //                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 17),
                                                                              //                           decoration: BoxDecoration(
                                                                              //                             color: const Color(0XFF353535),
                                                                              //                             borderRadius: BorderRadius.circular(10),
                                                                              //                           ),
                                                                              //                           child: Column(
                                                                              //                             children: [
                                                                              //                               const Text("Remaining\n Distance",
                                                                              //                                   textAlign: TextAlign.center,
                                                                              //                                   style: TextStyle(
                                                                              //                                     fontSize: 16,
                                                                              //                                     color: Colors.white,
                                                                              //                                   )),
                                                                              //                               Padding(
                                                                              //                                 padding: const EdgeInsets.only(top: 12.0),
                                                                              //                                 child: Text(
                                                                              //                                   "${Scooter.scooterData["remainingDistance"]} Km",
                                                                              //                                   style: const TextStyle(color: Color(0XFFFFC90E), fontSize: 22, fontWeight: FontWeight.bold),
                                                                              //                                 ),
                                                                              //                               )
                                                                              //                             ],
                                                                              //                           ),
                                                                              //                         ),
                                                                              //                         Container(
                                                                              //                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                                                              //                           decoration: BoxDecoration(
                                                                              //                             borderRadius: BorderRadius.circular(10),
                                                                              //                             color: const Color(0XFF353535),
                                                                              //                           ),
                                                                              //                           child: Column(
                                                                              //                             children: [
                                                                              //                               Text("${Scooter.scooterData["battery"]}%",
                                                                              //                                   textAlign: TextAlign.center,
                                                                              //                                   style: const TextStyle(
                                                                              //                                     fontSize: 20,
                                                                              //                                     fontWeight: FontWeight.bold,
                                                                              //                                     color: Colors.white,
                                                                              //                                   )),
                                                                              //                               Padding(
                                                                              //                                 padding: const EdgeInsets.only(top: 12.0),
                                                                              //                                 child: BatteryIndicator(
                                                                              //                                   batteryFromPhone: false,
                                                                              //                                   batteryLevel: Scooter.scooterData["battery"],
                                                                              //                                   style: BatteryIndicatorStyle.skeumorphism,
                                                                              //                                   colorful: true,
                                                                              //                                   showPercentNum: false,
                                                                              //                                   mainColor: Theme.of(context).primaryColor,
                                                                              //                                   size: 13,
                                                                              //                                   ratio: 3,
                                                                              //                                 ),
                                                                              //                               )
                                                                              //                             ],
                                                                              //                           ),
                                                                              //                         ),
                                                                              //                       ],
                                                                              //                     ),
                                                                              //                     Center(child: Image.asset("images/icons/scooter-qr-code-icon.png", width: 280)),
                                                                              //                   ],
                                                                              //                 ),
                                                                              //               ),
                                                                              //               Column(
                                                                              //                 children: [
                                                                              //                   InkWell(
                                                                              //                     onTap: () async {
                                                                              //                       await getDataScooter(Scooter.scootersData[index]["id"]);
                                                                              //                       if (!mounted) return;
                                                                              //                       if ((Scooter.scooterData["isReserved"] == true && Scooter.scooterData["rider"] != Users.userData["userId"]) || Scooter.scooterData["isScanned"] == true) {
                                                                              //                         showModalBottomSheet(
                                                                              //                             backgroundColor: Colors.transparent,
                                                                              //                             context: context,
                                                                              //                             builder: (context) {
                                                                              //                               return Container(
                                                                              //                                 decoration: BoxDecoration(
                                                                              //                                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                                              //                                   color: Theme.of(context).primaryColorDark,
                                                                              //                                 ),
                                                                              //                                 height: MediaQuery.of(context).size.height / 2,
                                                                              //                                 child: Center(
                                                                              //                                   child: SingleChildScrollView(
                                                                              //                                       child: Column(
                                                                              //                                     children: [
                                                                              //                                       Icon(
                                                                              //                                         Icons.warning_rounded,
                                                                              //                                         color: Colors.amber[400],
                                                                              //                                         size: 200,
                                                                              //                                       ),
                                                                              //                                       const Padding(
                                                                              //                                         padding: EdgeInsets.only(top: 20.0),
                                                                              //                                         child: Text(
                                                                              //                                           "This scooter is taken!",
                                                                              //                                           style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                         ),
                                                                              //                                       ),
                                                                              //                                       const Padding(
                                                                              //                                         padding: EdgeInsets.only(top: 15.0),
                                                                              //                                         child: Text(
                                                                              //                                           "Look for another one",
                                                                              //                                           style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                         ),
                                                                              //                                       )
                                                                              //                                     ],
                                                                              //                                   )),
                                                                              //                                 ),
                                                                              //                               );
                                                                              //                             });
                                                                              //                       } else {
                                                                              //                         Navigator.pop(context);
                                                                              //                         await showModalBottomSheet(
                                                                              //                             context: context,
                                                                              //                             builder: (context) {
                                                                              //                               return Container(
                                                                              //                                 decoration: const BoxDecoration(
                                                                              //                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                                              //                                 ),
                                                                              //                                 height: MediaQuery.of(context).size.height / 2,
                                                                              //                                 child: Stack(
                                                                              //                                   alignment: Alignment.topRight,
                                                                              //                                   children: [
                                                                              //                                     QRView(
                                                                              //                                       key: qrKey,
                                                                              //                                       onQRViewCreated: (QRViewController controller) {
                                                                              //                                         controller.resumeCamera();
                                                                              //                                         qrController = controller;
                                                                              //                                         controller.scannedDataStream.listen((scanData) async {
                                                                              //                                           if (scanData.code != "") {
                                                                              //                                             if (scanData.code == Scooter.scootersData[index]["qrCode"] && Scooter.scootersData[index]["rider"] == Users.userData["userId"] || Scooter.scootersData[index]["rider"] == "") {
                                                                              //                                               qrController!.dispose();
                                                                              //                                               getDataScooter(Scooter.scootersData[index]["id"]);
                                                                              //                                               await updateState(Scooter.scootersData[index]["id"]);
                                                                              //                                             } else {
                                                                              //                                               qrController!.dispose();
                                                                              //                                               await showModalBottomSheet(
                                                                              //                                                   backgroundColor: Colors.transparent,
                                                                              //                                                   context: context,
                                                                              //                                                   builder: (context) {
                                                                              //                                                     return Container(
                                                                              //                                                       decoration: BoxDecoration(
                                                                              //                                                         borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                                              //                                                         color: Theme.of(context).primaryColorDark,
                                                                              //                                                       ),
                                                                              //                                                       height: MediaQuery.of(context).size.height / 2,
                                                                              //                                                       child: Center(
                                                                              //                                                         child: SingleChildScrollView(
                                                                              //                                                             child: Column(
                                                                              //                                                           children: [
                                                                              //                                                             Icon(
                                                                              //                                                               Icons.warning_rounded,
                                                                              //                                                               color: Colors.amber[400],
                                                                              //                                                               size: 200,
                                                                              //                                                             ),
                                                                              //                                                             const Padding(
                                                                              //                                                               padding: EdgeInsets.only(top: 20.0),
                                                                              //                                                               child: Text(
                                                                              //                                                                 "This scooter is taken!",
                                                                              //                                                                 style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                                               ),
                                                                              //                                                             ),
                                                                              //                                                             const Padding(
                                                                              //                                                               padding: EdgeInsets.only(top: 15.0),
                                                                              //                                                               child: Text(
                                                                              //                                                                 "Look for another one",
                                                                              //                                                                 style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                                               ),
                                                                              //                                                             )
                                                                              //                                                           ],
                                                                              //                                                         )),
                                                                              //                                                       ),
                                                                              //                                                     );
                                                                              //                                                   });
                                                                              //                                               qrController!.resumeCamera();
                                                                              //                                             }
                                                                              //                                           }
                                                                              //                                         });
                                                                              //                                       },
                                                                              //                                       overlay: QrScannerOverlayShape(
                                                                              //                                         overlayColor: Theme.of(context).backgroundColor.withOpacity(.8),
                                                                              //                                         borderColor: Theme.of(context).primaryColor,
                                                                              //                                         borderRadius: 10,
                                                                              //                                         borderLength: 30,
                                                                              //                                         borderWidth: 3,
                                                                              //                                       ),
                                                                              //                                     ),
                                                                              //                                     Padding(
                                                                              //                                       padding: const EdgeInsets.only(top: 20.0, right: 15),
                                                                              //                                       child: InkWell(
                                                                              //                                           onTap: () async {
                                                                              //                                             await qrController?.toggleFlash();
                                                                              //                                           },
                                                                              //                                           child: Image.asset('images/icons/flashlight.png', width: 50)),
                                                                              //                                     ),
                                                                              //                                   ],
                                                                              //                                 ),
                                                                              //                               );
                                                                              //                             }).whenComplete(() async => await getDataUser());
                                                                              //                       }
                                                                              //                     },
                                                                              //                     child: Container(
                                                                              //                       padding: const EdgeInsets.only(top: 11, bottom: 11, left: 24, right: 30),
                                                                              //                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).primaryColor),
                                                                              //                       child: Row(
                                                                              //                         mainAxisSize: MainAxisSize.min,
                                                                              //                         children: [
                                                                              //                           const Icon(
                                                                              //                             Icons.lock_open_rounded,
                                                                              //                             size: 30,
                                                                              //                           ),
                                                                              //                           Padding(
                                                                              //                             padding: const EdgeInsets.only(left: 8.0),
                                                                              //                             child: Text(
                                                                              //                               "Unlock",
                                                                              //                               style: TextStyle(
                                                                              //                                 color: Theme.of(context).backgroundColor,
                                                                              //                                 fontSize: 18,
                                                                              //                                 fontWeight: FontWeight.bold,
                                                                              //                               ),
                                                                              //                             ),
                                                                              //                           ),
                                                                              //                         ],
                                                                              //                       ),
                                                                              //                     ),
                                                                              //                   ),
                                                                              //                   Padding(
                                                                              //                     padding: const EdgeInsets.only(top: 12.0),
                                                                              //                     child: InkWell(
                                                                              //                       onTap: () async {
                                                                              //                         await getDataScooter(Scooter.scooterData["id"]);
                                                                              //                         if (!mounted) return;
                                                                              //                         if ((Scooter.scooterData["isReserved"] == true && Scooter.scooterData["rider"] != Users.userData["userId"]) || Scooter.scooterData["isScanned"] == true) {
                                                                              //                           showModalBottomSheet(
                                                                              //                               backgroundColor: Colors.transparent,
                                                                              //                               context: context,
                                                                              //                               builder: (context) {
                                                                              //                                 return Container(
                                                                              //                                   decoration: BoxDecoration(
                                                                              //                                     borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                                              //                                     color: Theme.of(context).primaryColorDark,
                                                                              //                                   ),
                                                                              //                                   height: MediaQuery.of(context).size.height / 2,
                                                                              //                                   child: Center(
                                                                              //                                     child: SingleChildScrollView(
                                                                              //                                         child: Column(
                                                                              //                                       children: [
                                                                              //                                         Icon(
                                                                              //                                           Icons.warning_rounded,
                                                                              //                                           color: Colors.amber[400],
                                                                              //                                           size: 200,
                                                                              //                                         ),
                                                                              //                                         const Padding(
                                                                              //                                           padding: EdgeInsets.only(top: 20.0),
                                                                              //                                           child: Text(
                                                                              //                                             "This scooter is taken!",
                                                                              //                                             style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                           ),
                                                                              //                                         ),
                                                                              //                                         const Padding(
                                                                              //                                           padding: EdgeInsets.only(top: 15.0),
                                                                              //                                           child: Text(
                                                                              //                                             "Look for another one",
                                                                              //                                             style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              //                                           ),
                                                                              //                                         )
                                                                              //                                       ],
                                                                              //                                     )),
                                                                              //                                   ),
                                                                              //                                 );
                                                                              //                               });
                                                                              //                         } else {
                                                                              //                           if (Scooter.scooterData["isReserved"] == false) {
                                                                              //                             await streamReserved(Scooter.scooterData["id"], setStateSetter, Scooter.scooterData["rider"], true, 1);
                                                                              //                           } else {
                                                                              //                             await streamReserved(Scooter.scooterData["id"], setStateSetter, Scooter.scooterData["rider"], false, 1);
                                                                              //                           }
                                                                              //                         }
                                                                              //                       },
                                                                              //                       child: Container(
                                                                              //                         padding: const EdgeInsets.only(top: 11, bottom: 15, left: 22, right: 28),
                                                                              //                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).primaryColor),
                                                                              //                         child: Row(
                                                                              //                           mainAxisSize: MainAxisSize.min,
                                                                              //                           children: [
                                                                              //                             const Icon(
                                                                              //                               Icons.calendar_month_rounded,
                                                                              //                               size: 30,
                                                                              //                             ),
                                                                              //                             Padding(
                                                                              //                               padding: const EdgeInsets.only(left: 8.0),
                                                                              //                               child: Text(
                                                                              //                                 (Scooter.scooterData["isReserved"] == false && Scooter.scooterData["rider"] != Users.userData["userId"]) || Scooter.scooterData["isScanned"] == true ? "Reserve" : "Annuler reserve",
                                                                              //                                 style: TextStyle(
                                                                              //                                   color: Theme.of(context).backgroundColor,
                                                                              //                                   fontSize: 18,
                                                                              //                                   fontWeight: FontWeight.bold,
                                                                              //                                 ),
                                                                              //                               ),
                                                                              //                             ),
                                                                              //                           ],
                                                                              //                         ),
                                                                              //                       ),
                                                                              //                     ),
                                                                              //                   )
                                                                              //                 ],
                                                                              //               )
                                                                              //             ],
                                                                              //           )),
                                                                              //         );
                                                                              //       });
                                                                              //     }).whenComplete(() => getDataUser());
                                                                              showModalBottom(Scooter.scooterData["id"]);
                                                                            },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            "Scooter ${Scooter.scootersData[index]["id"]}",
                                                                            style: TextStyle(
                                                                                color: Theme.of(context).primaryColor,
                                                                                fontSize: 19,
                                                                                fontWeight: FontWeight.bold)),
                                                                        subtitle:
                                                                            Text(
                                                                          Scooter.scootersData[index]
                                                                              [
                                                                              "qrCode"],
                                                                          style:
                                                                              const TextStyle(color: Colors.white),
                                                                        ),
                                                                        trailing:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            if (Scooter.scootersData[index]["isReserved"] == true &&
                                                                                Scooter.scootersData[index]["rider"] != Users.userData["userId"])
                                                                              const Text("Reserved", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                            if (Scooter.scootersData[index]["battery"] <
                                                                                30)
                                                                              const Text("Low battery", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                            if (Scooter.scootersData[index]["rider"] != Users.userData["userId"] &&
                                                                                Scooter.scootersData[index]["isScanned"] == true)
                                                                              const Text("Used", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                            // BatteryIndicator(
                                                                            //   batteryFromPhone: false,
                                                                            //   batteryLevel: Scooter.scootersData[index]["battery"],
                                                                            //   style: BatteryIndicatorStyle.skeumorphism,
                                                                            //   colorful: true,
                                                                            //   showPercentNum: false,
                                                                            //   mainColor: Theme.of(context).primaryColor,
                                                                            //   size: 13,
                                                                            //   ratio: 3,
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16.0),
                                                                    child:
                                                                        Divider(
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }));
                                              });
                                            }).whenComplete(() {
                                          getDataUser();
                                        });
                                      }
                                    } // icon: await BitmapDescriptor.fromAssetImage(
                              //     const ImageConfiguration(size: Size(5, 5)), 'images/icons/618981.png'),
                              ),
                      },
                      zoomControlsEnabled: false,
                      myLocationEnabled: locationEnabled,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController googlemapcontroller) {
                        mapController = googlemapcontroller;
                      },
                      initialCameraPosition: const CameraPosition(
                          zoom: 17.0, target: LatLng(32.2164039, -7.9381082)),
                    ),
                    Column(
                      children: [
                        if (Users.userData["registerStatus"] == "Invalid")
                          InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context, SlideRight(page: const Step2()));
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.red[400]),
                              child: Row(
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  Text(
                                    "Please complete your registration",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if ((Users.userData["qrcodeScanned"] == true ||
                            isBarShowing == true))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Your ride is ongoing...",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
  }
}
