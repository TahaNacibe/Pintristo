import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pintresto/dialogs/information_bar.dart';

Future<bool> requestStoragePermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
  } else {
    return await Permission.storage.request().isGranted;
  }
}

class ImageDownloader {
  static Future<void> downloadImage(String url, BuildContext context) async {
    if (!await requestStoragePermissions()) {
      informationBar(context, 'Storage permission is required.');
      return null;
    }

    try {
      Dio dio = Dio();

      // Get the DCIM/Pintristo folder directory
      final Directory dcimDir = Directory('/storage/emulated/0/DCIM/Pintristo');

      // Ensure the DCIM/Pintristo directory exists
      if (!await dcimDir.exists()) {
        await dcimDir.create(recursive: true);
      }

      // Generate a unique file name
      String fileName = 'Pintristo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = path.join(dcimDir.path, fileName);

      // Download the image using Dio and save it to the specified path
      await dio.download(url, filePath);
      informationBar(context, "Image saved successfully");
    } catch (e) {
      informationBar(context, "Error downloading image: $e");
    }
  }
}
