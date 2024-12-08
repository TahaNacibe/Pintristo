import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';

//* update values
class Updater {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> updateListField(
      {required String userId,
      required String fieldName,
      required String item,
      required BuildContext context,
      required String collection,
      required bool isAdd}) async {
    // Reference to the Firestore document
    final docRef = _firestore.collection(collection).doc(userId);

    try {
      if (isAdd) {
        // Use FieldValue.arrayUnion to add the item if it doesn't already exist
        await docRef.update({
          fieldName: FieldValue.arrayUnion([item]),
        });
      } else {
        // Use FieldValue.arrayRemove to delete the item from the list
        await docRef.update({
          fieldName: FieldValue.arrayRemove([item]),
        });
      }
    } catch (e) {
      informationBar(context,"Error updating document: $e");
    }
  }
  
}