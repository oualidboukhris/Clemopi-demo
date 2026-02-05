import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clemopi_app/animation/animateroute.dart';
import 'package:clemopi_app/layout/show_doc.dart';

class PageScanDoc extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String typeCard;

  const PageScanDoc(
    this.cameras,
    this.typeCard, {
    super.key,
  });

  @override
  PageScanDocState createState() => PageScanDocState();
}

class PageScanDocState extends State<PageScanDoc> {
  late CameraController cameracontroller =
      CameraController(widget.cameras![0], ResolutionPreset.medium);
  XFile? filepicture;

  bool flashturn = false;
  Permission permissionCamera = Permission.camera;
  Permission permissionaudio = Permission.microphone;
  Permission permissionstorage = Permission.manageExternalStorage;

  @override
  void initState() {
    cameracontroller =
        CameraController(widget.cameras![0], ResolutionPreset.veryHigh);
    cameracontroller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    cameracontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text("Take a picture of your card"),
      ),
      body: !cameracontroller.value.isInitialized
          ? Container(
              color: Theme.of(context).primaryColor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(cameracontroller,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () async {
                              if (flashturn) {
                                cameracontroller.setFlashMode(FlashMode.torch);
                                cameracontroller.setFocusMode(FocusMode.auto);
                              } else {
                                cameracontroller.setFlashMode(FlashMode.off);
                              }
                              filepicture =
                                  await cameracontroller.takePicture();
                              // ignore: use_build_context_synchronously
                              await Navigator.pushReplacement(
                                  context,
                                  SlideRight(
                                      page: ShowDoc(
                                          filepicture!.path, widget.typeCard)));
                            },
                            child: Icon(
                              Icons.camera,
                              color: Theme.of(context).primaryColor,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, top: 30),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                              onPressed: () async {
                                if (flashturn) {
                                  cameracontroller.setFlashMode(FlashMode.off);
                                  flashturn = false;
                                  setState(() {});
                                } else {
                                  flashturn = true;
                                  setState(() {});
                                }
                              },
                              child: flashturn
                                  ? Icon(
                                      Icons.flash_on,
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    )
                                  : Icon(
                                      Icons.flash_off_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 28,
                                    )),
                        ),
                      )
                    ],
                  )),
            ),
    );
  }
}
