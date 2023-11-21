import 'dart:io';
import 'dart:typed_data';

import 'package:cutpaste/components/server/serverimage.dart';
import 'package:cutpaste/tools/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MyServer extends HookWidget with network {
  String ip = "";
  MyServer({super.key});
  ServerSocket? server, comserver;

  Socket? socket, comsocket;

  void createServer(
      {required int port,
      required String ip,
      required BuildContext context}) async {
    if (isInvalidPort(port) || !isValidIP(ip)) {
      Message(context: context, error: "Invalid Port");
      return;
    }
    try {
      server = await ServerSocket.bind(ip, port);
      comserver = await ServerSocket.bind(ip, port + 1);

      comserver!.listen((Socket socket) {
        Message(context: context, error: "Comsocket connected");
        comsocket = socket;
      });

      server!.listen((Socket socket) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServerImage(
                    server: server,
                    socket: socket,
                    comserver: comserver,
                    comsocket: comsocket)));
      });
    } catch (e) {
      Message(context: context, error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Color mycolor = Theme.of(context).primaryColor;

    MaterialStateProperty<Color?> myproperty;
    myproperty = MaterialStateProperty.resolveWith((states) {
      // If the button is pressed, return green, otherwise blue
      if (states.contains(MaterialState.pressed)) {
        return mycolor;
      }
      return mycolor;
    });
    final myIp = useState("");
    final enteredPort = useState("");
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
            onChanged: (String s) => enteredPort.value = s,
            decoration: const InputDecoration(hintText: "Connect to PORT"),
          )),
          const Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  style: ButtonStyle(backgroundColor: myproperty),
                  onPressed: () => createServer(
                      ip: myIp.value,
                      port: int.parse(enteredPort.value),
                      context: context),
                  child: const Text(
                    "Create Server",
                    style: TextStyle(color: Colors.white),
                  )),
              const Padding(padding: EdgeInsets.all(5)),
              TextButton(
                  style: ButtonStyle(backgroundColor: myproperty),
                  onPressed: () => closeServer(
                      server: server,
                      ip: myIp.value,
                      port: int.parse(enteredPort.value),
                      context: context),
                  child: const Text(
                    "Close Server",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          )
        ],
      ),
    ));
  }
}
