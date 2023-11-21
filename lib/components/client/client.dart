import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cutpaste/components/client/clientimage.dart';
import 'package:cutpaste/tools/common.dart';
import 'package:cutpaste/tools/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

// ignore: must_be_immutable
class MyClient extends HookWidget with network, common {
  String ip = "";
  MyClient({super.key, required this.camera});
  Socket? socket, comsocket;
  CameraDescription? camera;
  MaterialStateProperty<Color?>? myproperty;
  void getDataFromServer(Uint8List data) {
    print(data.toString());
  }

  void connect(
      {required String ip,
      required int port,
      required BuildContext context}) async {
    if (ip == "" || !isValidIP(ip) || isInvalidPort(port)) {
      Message(context: context, error: "Invalid Ip or Port");
      return;
    }

    try {
      comsocket = await Socket.connect(ip, port + 1);

      socket = await Socket.connect(ip, port);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClientImage(
                  camera: camera, socket: socket, comsocket: comsocket)));
    } catch (e) {
      Message(context: context, error: e.toString());
    }
  }

  // ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    myproperty = getPrimaryColor(context);
    // If the button is pressed, return green, otherwise blue

    final myIp = useState("");
    final enteredIp = useState("");
    final enterPort = useState("");

    useEffect(() {
      Future<String> getdata() async {
        String s = await getIPAddress();

        myIp.value = s;

        return s;
      }

      getdata();

      return null;
    }, []);
    return Expanded(
        child: Container(
      padding: const EdgeInsets.only(top: 30),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            myIp.value,
            style: const TextStyle(
              decoration: TextDecoration.none,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          Material(
            child: TextField(
              onChanged: (String s) => enteredIp.value = s,
              decoration: const InputDecoration(hintText: "Connect to IP"),
            ),
          ),
          Material(
              child: TextField(
            onChanged: (String s) => enterPort.value = s,
            decoration: const InputDecoration(hintText: "Connect to PORT"),
          )),
          const Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  style: ButtonStyle(backgroundColor: myproperty),
                  onPressed: () => connect(
                      ip: enteredIp.value,
                      port: int.parse(enterPort.value),
                      context: context),
                  child: const Text(
                    "Connect",
                    style: TextStyle(color: Colors.white),
                  )),
              const Padding(padding: EdgeInsets.all(5)),
              TextButton(
                  style: ButtonStyle(backgroundColor: myproperty),
                  onPressed: () => Disconnect(
                      socket: socket,
                      ip: enteredIp.value,
                      port: int.parse(enterPort.value),
                      context: context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          )
        ],
      ),
    ));
  }
}
