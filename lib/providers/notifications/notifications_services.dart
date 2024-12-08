import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/keys/actions_keys.dart';
import 'package:pintresto/models/notification_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/workManager/notification_pop_up.dart';
import 'package:pintresto/screens/Chats/chats/chat_room.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/screens/home_page.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:uuid/uuid.dart';

class NotificationsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserServices userServices;
  final AuthServices _authServices = AuthServices();

  NotificationsServices({required this.userServices});

  Future<void> sendNotification(
      {required Map<String, dynamic> notificationJson,
      required BuildContext context,
      required String receiverId}) async {
    try {
      DocumentReference docRef = _firestore.collection("users").doc(receiverId);
      DocumentSnapshot docInst =
          await _firestore.collection("users").doc(receiverId).get();
      if (docInst.exists) {
        Map<String, dynamic> data = docInst.data() as Map<String, dynamic>;
        List<dynamic> notificationsList = data["notifications"];
        if (notificationJson["actionType"] == newMessage) {
          int index = 0;
          bool isExist = false;
          for (Map<String, dynamic> notify in notificationsList) {
            if (notify["actionType"] == newMessage) {
              notificationsList[index] = notificationJson;
              isExist = true;
            }
            index += 1;
          }
          if (!isExist) {
            notificationsList.add(notificationJson);
          }
          docRef.set({
            "notifications": notificationsList,
          }, SetOptions(merge: true));
        } else {
          docRef.set({
            "notifications": FieldValue.arrayUnion([notificationJson]),
          }, SetOptions(merge: true));
        }
      }
    } on FirebaseFirestore catch (e) {
      informationBar(context, "error sending $e");
    }
  }

  //* sent notification when following a new user
  Future<void> sendNotificationForFollow(
      {required String receiverId, required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
        id: const Uuid().v4(),
        destinationId: _authServices.getTheCurrentUserId(),
        title: "${user.userName} Just started following you",
        pfpUrl: user.pfpUrl,
        timestamp: Timestamp.now(),
        name: user.userName,
        actionType: newFollow,
      );

      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* sent a notification when liking a post for a user
  Future<void> sendNotificationForLikeAPost(
      {required String receiverId,
      required String postId,
      required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
        id: const Uuid().v4(),
        destinationId: postId,
        title: "${user.userName} Liked Your Pin",
        pfpUrl: user.pfpUrl,
        timestamp: Timestamp.now(),
        name: user.userName,
        actionType: newLike,
      );

      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* send in case a comment in post
  Future<void> sendNotificationForCommenting(
      {required String receiverId,
      required String comment,
      required String postId,
      required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
          id: const Uuid().v4(),
          destinationId: postId,
          title: "${user.userName} Commented on your Pin",
          pfpUrl: user.pfpUrl,
          timestamp: Timestamp.now(),
          name: user.userName,
          actionType: newComment,
          desc: comment);
      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* in case of react on a comment
  Future<void> sendNotificationForReactingOnComment(
      {required String receiverId,
      required String postId,
      required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
        id: const Uuid().v4(),
        destinationId: postId,
        title: "${user.userName}Just reacted on your comment",
        pfpUrl: user.pfpUrl,
        timestamp: Timestamp.now(),
        name: user.userName,
        actionType: newReact,
      );

      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* in case of react on a comment
  Future<void> sendNotificationForMessages(
      {required String receiverId,
      required String message,
      required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
        id: const Uuid().v4(),
        destinationId: receiverId,
        title: user.userName,
        pfpUrl: user.pfpUrl,
        timestamp: Timestamp.now(),
        desc: message,
        name: user.userName,
        actionType: newMessage,
      );

      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* replay on a comment
  //* send in case a comment in post
  Future<void> sendNotificationForReplaying(
      {required String receiverId,
      required String comment,
      required String postId,
      required BuildContext context}) async {
    UserModel? user = await userServices.getUserDetails(context);
    if (user != null) {
      //* create the notification
      NotificationModel notify = NotificationModel(
          id: const Uuid().v4(),
          destinationId: postId,
          title: "${user.userName} Replayed",
          pfpUrl: user.pfpUrl,
          timestamp: Timestamp.now(),
          name: user.userName,
          actionType: newReplay,
          desc: comment);

      //* sent the notification
      sendNotification(
          context: context,
          notificationJson: notify.toMap(),
          receiverId: receiverId);
    }
  }

  //* load notifications
  Future<List<NotificationModel>> loadUserNotifications(
      BuildContext context) async {
    List<NotificationModel> userNotifications = [];
    try {
      UserModel? user = await userServices.getUserDetails(context);
      if (user != null) {
        userNotifications = user.notifications;
      }
      return userNotifications;
    } catch (e) {
      return [];
    }
  }

  //* action on click
  void actionForNotification(
      {required NotificationModel notify, required BuildContext context}) {
    switch (notify.actionType) {
      case newFollow:
        //* go to the user profile page
        nwFollowAction(context: context, userId: notify.destinationId);
        break;
      case newComment:
        postRelatedAction(
            context: context,
            postId: notify.destinationId,
            showBottomSheet: true);
        break;
      case newLike:
        postRelatedAction(
            context: context,
            postId: notify.destinationId,
            showBottomSheet: false);
        break;
      case newReact:
        postRelatedAction(
            context: context,
            postId: notify.destinationId,
            showBottomSheet: false);
        break;
      case newReplay:
        postRelatedAction(
            context: context,
            postId: notify.destinationId,
            showBottomSheet: true);
        break;
      case newMessage:
        chatRelatedAction(context: context, senderId: notify.destinationId);
        break;
      default:
        informationBar(context, "Something went wrong");
    }
  }

  //* new follow case
  void nwFollowAction({required BuildContext context, required String userId}) {
    Navigator.push(
        context,
        (MaterialPageRoute(
            builder: (context) => ProfilePage(
                  isCurrentUser: false,
                  userId: userId,
                ))));
  }

  //* new follow case
  void messageCase({required BuildContext context, required String userId}) {
    Navigator.push(
        context, (MaterialPageRoute(builder: (context) => HomePage())));
  }

  //* post related
  void postRelatedAction(
      {required BuildContext context,
      required String postId,
      required bool showBottomSheet}) {
    PostsServices postsServices = PostsServices(userServices: userServices);
    showLoadingDialog(context);
    postsServices.getPostById(postId: postId, context: context).then((post) {
      Navigator.pop(context);
      if (post != null) {
        Navigator.push(
            context,
            (MaterialPageRoute(
                builder: (context) => PinScreen(
                      post: post,
                      showBottomSheet: showBottomSheet,
                      deleteAction: (postId) {},
                    ))));
      } else {
        informationBar(context, "Failed to load Pin");
      }
    });
  }

  //* chat related
  void chatRelatedAction({
    required BuildContext context,
    required String senderId,
  }) {
    final ChatServices _chatServices = ChatServices();

    List<String> ids = [senderId, userServices.getCurrentUserId()];
    ids.sort();
    String chatId = ids.join("_");
    showLoadingDialog(context);
    _chatServices
        .isUserBlocked(
            userId: _authServices.getTheCurrentUserId(), chatId: chatId)
        .then((answer) {
      if (answer != null) {
        userServices
            .getOtherUserDetails(userId: senderId, context: context)
            .then((user) {
          Navigator.pop(context);
          Navigator.push(
              context,
              (MaterialPageRoute(
                  builder: (context) => ChatRoom(
                      receiverName: user!.userName,
                      receiverPfp: user.pfpUrl,
                      chatId: chatId,
                      isBlocked: answer))));
        });
      } else {
        return;
      }
    });
  }

  Future<void> updateNotifications(
      {required NotificationModel notification}) async {
    String userId = userServices.getCurrentUserId();

    DocumentSnapshot docSnap =
        await _firestore.collection("users").doc(userId).get();

    if (docSnap.exists) {
      // Retrieve the 'notifications' field specifically as a List of maps
      List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(docSnap.get("notifications"));

      // Find the notification and update its 'isSeen' field
      for (int index = 0; index < notifications.length; index++) {
        if (notifications[index]["id"] == notification.id) {
          notifications[index]["isSeen"] = true;
          break; // Exit the loop once the matching notification is found and updated
        }
      }

      // Update Firestore with the modified notifications list
      await _firestore
          .collection("users")
          .doc(userId)
          .update({"notifications": notifications});
    }
  }

  Future<void> deleteItems({required List<NotificationModel> items}) async {
    List<String> selectedIds = items.map((each) => each.id).toList();
    String userId = userServices.getCurrentUserId();

    DocumentSnapshot docSnap =
        await _firestore.collection("users").doc(userId).get();

    if (docSnap.exists) {
      // Retrieve the 'notifications' field specifically as a List of maps
      List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(docSnap.get("notifications"));

      // Use removeWhere to delete notifications with matching IDs
      notifications.removeWhere((item) => selectedIds.contains(item["id"]));

      // Update Firestore with the modified notifications list
      await _firestore
          .collection("users")
          .doc(userId)
          .update({"notifications": notifications});
    } else {
      // Optionally handle the case where the document does not exist
    }
  }

  // Method to initialize Firestore listener
  void listenForNotifications(BuildContext context) {
    String userId = userServices.getCurrentUserId();
    _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        getAllowNotifications().then((notificationState) {
          // Get notifications field if it exists
          if (docSnapshot.data()!['notifications'] != null) {
            List<dynamic> notifications = docSnapshot.data()!['notifications'];
            if (notificationState) {
              for (var notificationData in notifications) {
                // Only process notifications that are not seen
                if (notificationData['isSeen'] == false) {
                  createNotification(
                    notificationData['title'],
                    notificationData['pfpUrl'], // Profile picture URL
                    notificationData['id']
                        .hashCode, // Use hashCode for unique ID
                    description:
                        notificationData['desc'], // Optional description
                  );

                  // Mark the notification as seen without triggering the listener
                  markNotificationAsSeen(userId, notificationData['id']);
                }
              }
            }
          }
        });
      }
    });
  }

  Future<void> markNotificationAsSeen(
      String userId, String notificationId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      List<dynamic> notifications = data['notifications'];

      // Find the notification to update
      for (var notification in notifications) {
        if (notification['id'] == notificationId) {
          // Only update if not already seen (avoiding unnecessary updates)
          if (!notification['isSeen']) {
            notification['isSeen'] = true; // Mark as seen
            break; // Stop searching once we've found the notification
          }
        }
      }

      // Update the whole notifications array with the modified one
      await _firestore.collection('users').doc(userId).update({
        'notifications': notifications,
      });
    }
  }

  Future<void> saveAllowNotifications(bool allowNotifications) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allowNotifications', allowNotifications);
  }

  Future<bool> getAllowNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Return the value, defaulting to false if it's not set
    return prefs.getBool('allowNotifications') ?? true;
  }
}
