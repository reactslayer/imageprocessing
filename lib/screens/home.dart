import 'package:camera/camera.dart';
import 'package:cutpaste/components/client/client.dart';
import 'package:cutpaste/components/client/clientimage.dart';
import 'package:cutpaste/components/server/server.dart';
import 'package:cutpaste/components/server/serverimage.dart';
import 'package:cutpaste/tools/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Home extends StatelessWidget {
  Home({super.key, required this.camera});
  CameraDescription? camera;
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
    return Expanded(
        child: Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: ListView(
        children: <Widget>[
          const Text("Your Ip address",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.none)),
          MyIp(),
          Row(
            children: [
              TextButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: myproperty),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyServer())),
                  child: const Text(
                    "Server",
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: myproperty),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyClient(
                                camera: camera,
                              ))),
                  child: const Text(
                    "Client",
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: myproperty),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServerImage(
                                socket: null,
                                server: null,
                                comserver: null,
                                comsocket: null,
                              ))),
                  child: const Text(
                    "Trial Server",
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: myproperty),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientImage(
                                camera: camera,
                                socket: null,
                                comsocket: null,
                              ))),
                  child: const Text(
                    "Trial Client",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          )
        ],
      ),
    ));
  }
}

class MyIp extends HookWidget with network {
  MyIp({super.key});

  @override
  Widget build(BuildContext context) {
    final myIp = useState("");

    useEffect(() {
      Future<String> getdata() async {
        String s = await getIPAddress();

        myIp.value = s;

        return s;
      }

      getdata();

      return null;
    }, []);

    return Text(myIp.value,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w900));
  }
}
