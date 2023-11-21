import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cutpaste/tools/common.dart';
import 'package:cutpaste/tools/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ClientImage extends StatefulWidget {
  ClientImage(
      {super.key,
      required this.socket,
      required this.camera,
      required this.comsocket});
  Socket? socket, comsocket;

  CameraDescription? camera;

  @override
  State<ClientImage> createState() => _ClientImageState();
}

enum ImageType { Background, Foreground }

class _ClientImageState extends State<ClientImage> with common, network {
  MaterialStateProperty<Color?>? myproperty;

  late CameraController _controller;

  late Future<void> _initializeControllerFuture;

  Future<void> takePicture({required ImageType img}) async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      XFile image = await _controller.takePicture();
      int len = await image.length();
      Map<String, String> info = {
        "message": "length",
        "data": len.toString(),
        "type": (img == ImageType.Background) ? "background" : "foreground"
      };

      widget.comsocket!.write(json.encode(info));
      await widget.comsocket!.flush();
      await widget.socket!.addStream(image.openRead());

      await widget.socket!.flush();
    } catch (e) {
      // If an error occurs, log the error to the console.
      Message(context: context, error: e.toString());
      print(e);
    }
  }

  void comsocketListen(Uint8List ls) {
    Map<String, dynamic> data = json.decode(utf8.decode(ls));
    String message = data["message"] as String;
    if (message == "request") {
      takePicture(img: ImageType.Foreground);
    }
    if (message == "requestbackground") {
      takePicture(img: ImageType.Background);
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera!,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    widget.comsocket!.listen(comsocketListen);
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myproperty = getPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.only(top: 40),
      color: Colors.white,
      child: Column(
        children: [
          FloatingActionButton(
              onPressed: () => takePicture(img: ImageType.Background),
              child: Icon(Icons.add)),
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
    );
  }
}
