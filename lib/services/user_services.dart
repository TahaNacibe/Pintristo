import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/services/updater.dart';

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();
  final Updater _updater = Updater();

  String getCurrentUserId() {
    String userId = _authServices.getTheCurrentUserId();
    return userId;
  }

  Future<UserModel?> getPostOwner(
      {required String id, required BuildContext context}) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(id).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      informationBar(context, "Failed to get post owner data $e");
      return null;
    }
  }

  Future<UserModel?> getUserDetails(BuildContext context) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(getCurrentUserId()).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      informationBar(context, "Failed to get user details $e");
      return null;
    }
  }

  Future<UserModel?> getOtherUserDetails(
      {required String userId, required BuildContext context}) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      informationBar(context, "Failed to get other users details $e");
      return null;
    }
  }

  //* follow a user
  Future<void> followUser(
      {required String followedUserId, required BuildContext context}) async {
    final NotificationsServices _notificationsServices =
        NotificationsServices(userServices: UserServices());

    //* add the owner id to your followed list
    _updater.updateListField(
        userId: getCurrentUserId(),
        fieldName: "followingIds",
        context: context,
        item: followedUserId,
        collection: "users",
        isAdd: true);
    //* add yourself to the owner followers list
    _updater.updateListField(
        userId: followedUserId,
        fieldName: "followersIds",
        context: context,
        item: getCurrentUserId(),
        collection: "users",
        isAdd: true);
    //* sent notification
    _notificationsServices.sendNotificationForFollow(
        receiverId: followedUserId, context: context);
  }

  //* UnFollow a user
  Future<void> unFollowUser(
      {required String followedUserId, required BuildContext context}) async {
    //* add the owner id to your followed list
    _updater.updateListField(
        userId: getCurrentUserId(),
        fieldName: "followingIds",
        context: context,
        item: followedUserId,
        collection: "users",
        isAdd: false);
    //* add yourself to the owner followers list
    _updater.updateListField(
        userId: followedUserId,
        fieldName: "followersIds",
        context: context,
        item: getCurrentUserId(),
        collection: "users",
        isAdd: false);
  }

  //* update user data
  void updateUserData(
      {required Map<String, dynamic> update, required BuildContext context}) {
    // Remove any null fields before updating Firestore
    update.removeWhere((key, value) => value == null);

    // Update Firestore document with only non-null data
    if (update.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(getCurrentUserId())
          .update(update)
          .then((_) {})
          .catchError((error) {
        informationBar(context, 'Error updating document: $error');
      });
    } else {
      informationBar(context, 'No fields to update.');
    }
  }

  //* update visible state
  Future<void> updateUserVisibility({required bool state}) async {
    try {
      DocumentReference docRef = _firestore
          .collection("users")
          .doc(_authServices.getTheCurrentUserId());
      docRef.update({"isVisible": state});
    } catch (e) {}
  }
}
