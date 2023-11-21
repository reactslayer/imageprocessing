import 'package:camera/camera.dart';
import 'package:cutpaste/screens/home.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Future<void> main() async {
  if (Platform.isWindows) {
    runApp(MyApp(camera: null));
    return;
  }
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    CameraDescription firstCamera = cameras.first;
    runApp(MyApp(camera: firstCamera));
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.camera});
  CameraDescription? camera;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Home(camera: camera),
    );
  }
}
