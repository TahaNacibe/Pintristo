import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';

class FireImageServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //* Upload image to storage
  Future<String> uploadImage(
      {required String filePath,
      required String userId,
      required BuildContext context}) async {
    try {
      File file = File(filePath);
      TaskSnapshot snapshot = await _storage
          .ref('Pins/$userId/${file.uri.pathSegments.last}')
          .putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      informationBar(context, "Error Uploading images $e");
      return "";
    }
  }
  //* Upload image to storage
  Future<String> uploadImageForChatBg(
      {required String filePath,
      required String chatId,
      required BuildContext context}) async {
    try {
      File file = File(filePath);
      TaskSnapshot snapshot = await _storage
          .ref('chats/$chatId/${file.uri.pathSegments.last}')
          .putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      informationBar(context, "Error Uploading images $e");
      return "";
    }
  }

  //* Upload image to storage
  Future<String> uploadCommentImage(
      {required String filePath,
      required String userId,
      required BuildContext context}) async {
    try {
      File file = File(filePath);
      TaskSnapshot snapshot = await _storage
          .ref('Comments/$userId/${file.uri.pathSegments.last}')
          .putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      informationBar(context, "Error Uploading comment image : $e");
      return "";
    }
  }

  //* upload the image into the storage
  Future<String> uploadImageIntoStorage(
      {required String imagePath, required BuildContext context}) async {
    String userId = _auth.currentUser!.uid;
    String url = await uploadImage(
        filePath: imagePath, userId: userId, context: context);
    return url;
  }

  //* delete image
  Future<void> deleteImageFromFirebase(
      String downloadUrl, BuildContext context) async {
    try {
      // Create a Firebase Storage reference from the download URL
      final Reference storageRef =
          FirebaseStorage.instance.refFromURL(downloadUrl);
      // Delete the file from Firebase Storage
      await storageRef.delete();
    } catch (e) {
      informationBar(context, 'Error deleting file: $e');
    }
  }

  //* upload user images
  Future<String> uploadUserImages(
      {required String imagePath,
      required String? oldImagePath,
      required BuildContext context}) async {
    try {
      File file = File(imagePath);
      TaskSnapshot snapshot = await _storage
          .ref(
              'userImages/${_auth.currentUser!.uid}/${file.uri.pathSegments.last}')
          .putFile(file);
      if (oldImagePath != null && oldImagePath.contains("firebasestorage")) {
        deleteImageFromFirebase(oldImagePath, context);
      }
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      informationBar(context, "Error uploading User Image $e");
      return "";
    }
  }
}
