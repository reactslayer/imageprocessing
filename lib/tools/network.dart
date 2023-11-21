import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

mixin network {
  Future<String> getIPAddress() async {
    final networkInfo = NetworkInfo();
    final wifiIP = await networkInfo.getWifiIP();
    return wifiIP ?? 'Unable to retrieve IP address';
  }

  bool isValidIP(String ip) {
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');

    return ipv4Regex.hasMatch(ip) || ipv6Regex.hasMatch(ip);
  }

  bool isInvalidPort(int port) {
    // Check if the port number is less than 0 or greater than 65535
    if (port < 0 || port > 65535) {
      return true;
    }

    // Check if the port number is reserved
    if (port == 0 ||
        port == 21 ||
        port == 22 ||
        port == 23 ||
        port == 25 ||
        port == 53 ||
        port == 80 ||
        port == 110 ||
        port == 119 ||
        port == 135 ||
        port == 139 ||
        port == 143 ||
        port == 1723 ||
        port == 3306 ||
        port == 5000 ||
        port == 8080) {
      return true;
    }

    return false;
  }

  void Disconnect(
      {required String ip,
      required int port,
      required BuildContext context,
      required Socket? socket}) async {
    try {
      await socket!.close();
      Message(context: context, error: "Closed Successfully!");
    } catch (e) {
      Message(context: context, error: e.toString());
    }
  }

  void closeServer(
      {required int port,
      required ServerSocket? server,
      required String ip,
      required BuildContext context}) async {
    try {
      await server!.close();
      Message(context: context, error: "Closed Successfully");
    } catch (e) {
      Message(context: context, error: e.toString());
    }
  }

  // ignore: non_constant_identifier_names
  void Message({required BuildContext context, required String error}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Dialog'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

enum PacketType { start, data, end }

class FileData {
  PacketType type;
  int? length;
  Uint8List? list;
  int? imageSize;

  FileData.start(this.type, {this.imageSize});
  FileData.data(this.type, {this.length, this.list});
  FileData.end(this.type);
  static Map<String, dynamic> toJson(FileData data) {
    return {
      'type': data.type,
      'length': data.length,
      'list': data.list,
      'imageSize': data.imageSize
    };
  }

  FileData.fromJson(this.type, Map<String, dynamic> json) {
    type = json["type"];
    length = json["length"];
    list = json["list"];
    imageSize = json["imageSize"];
  }
}
