import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/providers/workManager/notification_pop_up.dart';

void callbackDispatcher() {
  // Ensure Firebase is initialized in the background isolate
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase in the background isolate
    await Firebase.initializeApp();

    final UserServices userServices = UserServices();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Initialize SharedPreferences to check user notification preference
    final prefs = await SharedPreferences.getInstance();
    bool allowNotifications = prefs.getBool('allowNotifications') ?? true;

    if (allowNotifications) {
      // Specify the document to check for notifications
      String userId = userServices.getCurrentUserId();
      DocumentReference userDocRef = firestore.collection('users').doc(userId);

      // Fetch the current notifications
      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        List<dynamic> currentNotifications =
            userSnapshot['notifications'] ?? [];

        // Iterate over the notifications and send only unseen ones
        for (var notificationData in currentNotifications) {
          if (notificationData['isSeen'] == false) {
            // Create and show a notification
            createNotification(
              notificationData['title'],
              notificationData['pfpUrl'], // Profile picture URL
              notificationData['id'].hashCode, // Unique notification ID
              description: notificationData['desc'], // Optional description
            );

            // Mark the notification as seen in Firestore
            await markNotificationAsSeen(userId, notificationData['id']);
          }
        }
      }
    }

    return Future.value(true); // Task finished successfully
  });
}

// Function to mark a notification as seen
Future<void> markNotificationAsSeen(String userId, String notificationId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection('users').doc(userId);

  // Use a transaction to safely update the notification
  await firestore.runTransaction((transaction) async {
    DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
    
    if (userSnapshot.exists) {
      List<dynamic> notifications = userSnapshot['notifications'] ?? [];
      // Find the index of the notification to update
      var notificationToUpdate = notifications.firstWhere(
        (notification) => notification['id'] == notificationId,
        orElse: () => null,
      );

      if (notificationToUpdate != null) {
        // Update the 'isSeen' field of the specific notification
        notificationToUpdate['isSeen'] = true;

        // Update the notifications array in Firestore
        transaction.update(userDocRef, {
          'notifications': notifications,
        });
      }
    }
  });
}

