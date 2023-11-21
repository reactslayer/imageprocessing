import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:cutpaste/tools/network.dart';
import 'package:flutter/material.dart';

mixin common {
  MaterialStateProperty<Color?> getPrimaryColor(BuildContext context) {
    Color mycolor = Theme.of(context).primaryColor;

    return MaterialStatePropertyAll(mycolor);
  }

  Uint8List getList(Uint8List ls, int start) {
    int size = PACKETLOAD;

    if (start + PACKETLOAD > ls.length) {
      size = ls.length - start;
    }

    Uint8List ans = Uint8List(size);

    for (int a = start; a < start + size; a++) {
      ans[a - start] = ls[start];
    }

    return ans;
  }

  Future<void> startTransfer(Socket socket, Uint8List ls) async {
    int start = 0;

    while (start < ls.length) {
      Uint8List hold = getList(ls, start);

      FileData holder =
          FileData.data(PacketType.data, length: hold.length, list: hold);

      socket.write(FileData.toJson(holder));
      start += PACKETLOAD;
      await socket.flush();
    }
  }

  Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
        height: image.height,
        width: image.width,
        pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(
        targetHeight: image.height, targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  static int BACKIMAGE = 0;
  static int PAYLOAD = 1;
  static int PACKETLOAD = 1000;
}
