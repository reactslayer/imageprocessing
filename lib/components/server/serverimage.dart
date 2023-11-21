import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cutpaste/components/client/clientimage.dart';
import 'package:cutpaste/tools/common.dart';
import 'package:image/image.dart' as NinadImage;
import 'package:cutpaste/tools/network.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ServerImage extends StatefulWidget with network {
  ServerImage(
      {super.key,
      required this.server,
      required this.socket,
      required this.comserver,
      required this.comsocket});
  ServerSocket? server, comserver;
  Socket? socket, comsocket;

  @override
  State<ServerImage> createState() => _ServerImageState();
}

class _ServerImageState extends State<ServerImage> with common, network {
  Uint8List? imagebackground, imageforeground;
  List<int> data = [];
  int imageLength = 0;
  ui.Image? foreground;
  ByteData? background;
  ImageType? receive_type;
  int threshold = 1000;
  int radius = 2;
  void requestData() async {
    Map<String, String> msg = {"message": "request", "data": ""};

    widget.comsocket!.write(json.encode(msg));
    await widget.comsocket!.flush();
  }

  int abs(int b) {
    return (b < 0) ? -b : b;
  }

  double calculateDistance(int i, int j, int centerX, int centerY) {
    return sqrt(pow(i - centerX, 2) + pow(j - centerY, 2));
  }

  void setpixel(int x, int y, ByteData? bytes) {
    bytes!.setUint32((y * foreground!.width + x) * 4, 0x00000000);

    for (int i = x - radius; i <= x + radius; i++) {
      for (int j = y - radius; j <= y + radius; j++) {
        if (calculateDistance(i, j, x, y) <= radius) {
          try {
            bytes!.setUint32((j * foreground!.width + i) * 4, 0x00000000);
          } catch (e) {}
        }
      }
    }
  }

  bool replace(int bpixel, int fpixel) {
    int diff = 0;

    int red1 = (bpixel >> 16) & 0xFF;
    int red2 = (fpixel >> 16) & 0xFF;

    int green1 = (bpixel >> 8) & 0xFF;
    int green2 = (fpixel >> 8) & 0xFF;

    int blue1 = bpixel & 0xFF;
    int blue2 = fpixel & 0xFF;

    int alpha1 = (bpixel >> 24) & 0xFF;
    int alpha2 = (fpixel >> 24) & 0xFF;

    diff += (red1 - red2).abs();
    diff += (green1 - green2).abs();
    diff += (blue1 - blue2).abs();
    diff += (alpha1 - alpha2).abs();
    if (diff > threshold) {
      return false;
    }
    return true;
  }

  void imageCallback(ui.Image image) async {
    foreground = image;
    final ByteData? bytes = await foreground!.toByteData(
      format: ImageByteFormat.rawRgba,
    );

    // bytes!.setUint32(0, 0xFF0000FF);

    // Set pixel at (x, y) to green.

    //bytes.setUint32((y * image1!.width + x) * 4, 0x00FF00FF);

    for (int x = 0; x < foreground!.width; x++) {
      for (int y = 0; y < foreground!.height; y++) {
        int b = background!.getUint32((y * foreground!.width + x) * 4);
        int f = bytes!.getUint32((y * foreground!.width + x) * 4);

        if (replace(b, f)) {
          setpixel(x, y, bytes);
        }
      }
    }
    print("Done");
    ui.decodeImageFromPixels(
      bytes!.buffer.asUint8List(),
      foreground!.width,
      foreground!.height,
      ui.PixelFormat.rgba8888,
      (ui.Image result) async {
        ByteData? da = await result.toByteData(format: ImageByteFormat.png);
        setState(() => imageforeground = Uint8List.view(da!.buffer));
      },
    );
  }

  void imagebackgroundCallback(ui.Image image) async {
    background = await image!.toByteData(
      format: ImageByteFormat.rawRgba,
    );
    setState(() {});
  }

  void socketListen(Uint8List d) async {
    for (int a = 0; a < d.length; a++) {
      data.add(d[a]);
    }
    if (data.length == imageLength) {
      Message(context: context, error: "Complete image received");
      imageLength = 0;
      if (receive_type == ImageType.Background) {
        imagebackground = Uint8List.fromList(data);

        ui.decodeImageFromList(imagebackground!, imagebackgroundCallback);
      }
      if (receive_type == ImageType.Foreground) {
        imageforeground = Uint8List.fromList(data);
        ui.decodeImageFromList(imageforeground!, imageCallback);
      }

      data = [];
    }
  }

  void comsocketListen(Uint8List ls) {
    try {
      Map<String, dynamic> data = json.decode(utf8.decode(ls));

      if (data["message"] == "length") {
        imageLength = int.parse(data["data"]! as String);
      }
      String t = data["type"] as String;
      receive_type =
          (t == "background") ? ImageType.Background : ImageType.Foreground;
      //print("Data is" + json.decode());
    } catch (e) {
      print(e);
    }
  }

  void requestBackgroundData() async {
    Map<String, String> msg = {"message": "requestbackground", "data": ""};

    widget.comsocket!.write(json.encode(msg));
    await widget.comsocket!.flush();
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

    widget.socket!.listen(socketListen);
    widget.comsocket!.listen(comsocketListen);
  }

  MaterialStateProperty<Color?>? myproperty;
  @override
  Widget build(BuildContext context) {
    myproperty = getPrimaryColor(context);
    if (imagebackground == null || imageforeground == null) {
      if (imagebackground == null) {
        print("image back is null***************");
      } else {
        print("image fore is null***************");
      }
      return Row(
        children: [
          TextButton(
            onPressed: requestData,
            style: ButtonStyle(backgroundColor: myproperty),
            child: const Text(
              "Get ForeGround Image",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: requestBackgroundData,
            style: ButtonStyle(backgroundColor: myproperty),
            child: const Text(
              "Get Background Image",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: requestData,
                    style: ButtonStyle(backgroundColor: myproperty),
                    child: const Text(
                      "Get Foreground Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: requestBackgroundData,
                    style: ButtonStyle(backgroundColor: myproperty),
                    child: const Text(
                      "Get Background Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: SizedBox(
                        width: 50,
                        child: TextField(
                          decoration: InputDecoration(hintText: "Radius : 2"),
                          onChanged: (String v) =>
                              setState(() => {radius = int.parse(v)}),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: SizedBox(
                        width: 50,
                        child: TextField(
                          decoration:
                              InputDecoration(hintText: "Threshold : 1000"),
                          onChanged: (String v) =>
                              setState(() => {threshold = int.parse(v)}),
                        )),
                  )
                ],
              ),
              Row(
                children: [
                  Image(
                    image: Image.memory(imagebackground!).image,
                  ),
                  Image(
                    image: Image.memory(imageforeground!).image,
                  )
                ],
              )
            ],
          )),
    );
  }
}
