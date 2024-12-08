import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/chat_model.dart';
import 'package:pintresto/models/message_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/services/image_picker.dart';
import 'package:pintresto/services/image_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:uuid/uuid.dart';

class ChatServices {
  final AuthServices _firebaseServices = AuthServices();
  final UserServices _userServices = UserServices();
  final FireImageServices _fireImageServices = FireImageServices();
  final ImageServices _imageServices = ImageServices();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());

  // Create a chat ID in sorted order
  String getChatId(String userId, String receiverId) {
    List<String> ids = [userId, receiverId]..sort();
    return ids.join("_");
  }

  // Create a chat room
  Future<void> createChatRoom({
    required BuildContext context,
    required String receiverId,
  }) async {
    try {
      User? user = await _firebaseServices.getTheCurrentUser();
      String userId = user!.uid;
      // Create chat ID
      String chatId = getChatId(userId, receiverId);
      // Create the chat room document if it doesn't exist
      DocumentReference chatRoomRef =
          _fireStore.collection("chats").doc(chatId);

      // Check if chat room already exists
      DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
      if (!chatRoomSnapshot.exists) {
        // Create a new chat room document
        await chatRoomRef.set({
          "chatId": chatId,
          "participants": [userId, receiverId],
          "createdAt": FieldValue.serverTimestamp(),
          "lastMessage":
              "", // Optional: You can store the last message here for quick access
          "lastMessageTime": FieldValue.serverTimestamp(),
        });
      }

      // Update both users' chatIds list
      DocumentReference thisUserRef =
          _fireStore.collection("users").doc(userId);
      DocumentReference receiverRef =
          _fireStore.collection("users").doc(receiverId);

      await Future.wait([
        thisUserRef.update({
          "chatsIds": FieldValue.arrayUnion([chatId])
        }),
        receiverRef.update({
          "chatsIds": FieldValue.arrayUnion([chatId])
        }),
      ]);
    } catch (e) {
      informationBar(context, "Failed to create chat room $e");
    }
  }

  // Get chat rooms of the user, including receiver info
  Future<List<ChatModel>> userChats(BuildContext context) async {
    try {
      User? currentUser = await _firebaseServices.getTheCurrentUser();
      List<ChatModel> chats = [];

      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _fireStore.collection("users").doc(currentUser.uid).get();
        List<dynamic> chatIds = userDoc['chatsIds'] ?? [];
        if (chatIds.isEmpty) {
          return [];
        } else {
          for (String chatId in chatIds) {
            DocumentSnapshot chatDoc =
                await _fireStore.collection("chats").doc(chatId).get();
            if (chatDoc.exists) {
              // Get the chat model
              ChatModel chatModel =
                  ChatModel.fromJson(chatDoc.data() as Map<String, dynamic>);

              // Assuming chatId is formatted as "userId_receiverId"
              List<String> userIds = chatId.split("_");
              String receiverId = userIds.first == currentUser.uid
                  ? userIds.last
                  : userIds.first;

              // Fetch receiver details
              DocumentSnapshot receiverDoc =
                  await _fireStore.collection("users").doc(receiverId).get();
              if (receiverDoc.exists) {
                String receiverName = receiverDoc['userName'] ?? '';
                String receiverPfp = receiverDoc['pfpUrl'] ?? '';

                // Add receiver info to chat model
                chatModel.receiverName = receiverName;
                chatModel.receiverPfp = receiverPfp;
                chatModel.chatId = chatId;
              }

              chats.add(chatModel);
            }
          }
        }
      }
      return chats;
    } on FirebaseException catch (e) {
      informationBar(context, "Failed to get the user chats $e");
      return [];
    }
  }

  // Function to upload an image
  Future<String> uploadImage(String senderId, File imageFile, String chatId,
      BuildContext context, String uniqueFileName) async {
    try {
      String fileName = "$uniqueFileName.png"; // Ensure unique naming
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("chat_images/$chatId/$fileName");

      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      informationBar(context, "Error uploading image: $e");
      return "";
    }
  }

  // Function to send a message with optional image
  String getReceiverId(String chatId, String senderId) {
    List<String> ids = chatId.split("_");
    return ids[0] != senderId ? ids[0] : ids[1];
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
    required String? senderName,
    required String? senderPfp,
    required BuildContext context,
    List<String?>? images,
  }) async {
    try {
      List<String?> imageUrls = [];

      if (images != null && images.isNotEmpty) {
        // Use a Set to ensure unique paths are uploaded
        Set<String?> uniqueImages = images.toSet();

        // Use a list of futures to upload images concurrently
        List<Future<String?>> uploadFutures = uniqueImages.map((path) async {
          if (path != null) {
            // Generate a unique name for each image upload using UUID or timestamp
            String uniqueFileName =
                const Uuid().v4(); // Use UUID for uniqueness
            String? uploadedUrl = await uploadImage(
              senderId,
              File(path),
              chatId,
              context,
              uniqueFileName,
            );
            return uploadedUrl;
          }
          return null; // Handle potential null paths
        }).toList();

        // Wait for all uploads to complete and collect the URLs
        imageUrls = await Future.wait(uploadFutures);
      }

      // Create a reference to the message document
      DocumentReference messageRef = _fireStore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .doc();

      // Create the message object, attaching images if any were uploaded
      MessageModel messageModel = MessageModel(
        senderId: senderId,
        message: message,
        messageId: "",
        senderName: senderName,
        senderPfp: senderPfp,
        imageUrl: imageUrls
            .where((url) => url != null)
            .toList(), // Only keep non-null URLs
        timestamp: Timestamp.now(),
      );

      // Save the message in Firestore
      await messageRef.set(messageModel.toJson());
      String messageId = messageRef.id;
      messageRef.update({"messageId": messageId});

      // Update the last message info in the chat room collection
      await _fireStore.collection("chats").doc(chatId).update({
        'lastMessage': message,
        'lastMessageTimestamp': Timestamp.now(),
      });
      _notificationsServices.sendNotificationForMessages(
          receiverId: getReceiverId(chatId, senderId),
          message: message,
          context: context);
    } catch (e) {
      informationBar(context, "Failed to send message");
    }
  }

  Stream<List<MessageModel>>? getMessagesStream({
    required String chatId,
    required BuildContext context,
    required int limit,
  }) {
    try {
      return _fireStore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .orderBy('timestamp', descending: true)
          .limit(limit + 1)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      informationBar(context, "Failed to get messages $e");
      return null;
    }
  }

  // Check if chat room exists and return the last message
  Future<String?> checkChatRoomExistsAndGetLastMessage({
    required String receiverId,
  }) async {
    User? user = await _firebaseServices.getTheCurrentUser();
    // Create chat ID
    String chatId = getChatId(user!.uid, receiverId);

    // Reference to the chat room
    DocumentReference chatRoomRef = _fireStore.collection("chats").doc(chatId);

    // Fetch chat room data
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    // Check if the chat room exists
    if (chatRoomSnapshot.exists) {
      // Get the last message from the chat room data
      var chatData = chatRoomSnapshot.data() as Map<String, dynamic>;

      // Assuming 'lastMessage' is a field in the chat document
      String? lastMessage = chatData['lastMessage'];

      // Check if the last message is an image or text
      if (lastMessage != null && lastMessage.isNotEmpty) {
        if (lastMessage.toLowerCase().contains('http') ||
            lastMessage.toLowerCase().endsWith('.png') ||
            lastMessage.toLowerCase().endsWith('.jpg')) {
          return "Image"; // Return "Image" if it's an image
        }
        return lastMessage; // Return the last message text
      }
    }

    return null; // Return null if no chat room exists or no last message
  }

  // Get following users
  Future<List<Map<String, dynamic>>> getFollowedUsers(
      BuildContext context) async {
    try {
      List<Map<String, dynamic>> result = [];
      UserModel? currentUser = await _userServices.getUserDetails(context);
      for (String userId in currentUser!.followingIds) {
        UserModel? otherUser = await _userServices.getOtherUserDetails(
            userId: userId, context: context);
        result.add({
          "pfpUrl": otherUser!.pfpUrl,
          "userName": otherUser.userName,
          "userId": otherUser.userId,
        });
      }
      return result;
    } catch (e) {
      informationBar(context, "Failed to get the following list $e");
      return [];
    }
  }

  //* check if chat room exist
  Future<Map<String, dynamic>> isChatRoomExist(
      {required String userId,
      required String otherId,
      required BuildContext context}) async {
    String chatId = getChatId(userId, otherId);
    DocumentSnapshot messageRef =
        await _fireStore.collection("chats").doc(chatId).get();
    if (messageRef.exists) {
      Map<String, dynamic> data = messageRef.data() as Map<String, dynamic>;
      return {'chatId': chatId, "isBlocked": data["blocked"].contains(userId)};
    } else {
      await createChatRoom(receiverId: otherId, context: context);
      return {'chatId': chatId, "isBlocked": false};
    }
  }

  // delete a message
  Future<void> deleteMessage(
      {required String chatId,
      required String messageId,
      required BuildContext context}) async {
    try {
      DocumentSnapshot docSnap = await _fireStore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .doc(messageId)
          .get();
      if (docSnap.exists) {
        DocumentReference messDoc = _fireStore
            .collection("chats")
            .doc(chatId)
            .collection("messages")
            .doc(messageId);
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        if (!data["isDeleted"]) {
          messDoc.set({
            "isDeleted": true,
          }, SetOptions(merge: true));
          informationBar(context, "Deleted");
        }
      }
    } on FirebaseFirestore catch (e) {
      informationBar(context, "couldn't delete $e");
    }
  }

  //* delete chat from users
  Future<void> deleteChatFromBothUsers({
    required BuildContext context,
    required String chatId,
  }) async {
    try {
      // Get the chat document
      DocumentSnapshot chatSnap =
          await _fireStore.collection("chats").doc(chatId).get();

      if (chatSnap.exists) {
        // Split the chatId to get the user IDs (assuming the chatId is of the form 'user1_user2')
        List<String> users = chatId.split('_');

        // Remove the chatId from both users' records
        for (String id in users) {
          DocumentReference userRef = _fireStore.collection('users').doc(id);
          DocumentSnapshot userSnap = await userRef.get();

          if (userSnap.exists) {
            await userRef.update({
              "chatsIds": FieldValue.arrayRemove(
                  [chatId]) // Remove the chatId from user's chats list
            });
          }
        }

        // Now delete the messages inside the chat subcollection first
        CollectionReference messagesRef =
            _fireStore.collection("chats").doc(chatId).collection("messages");
        QuerySnapshot messagesSnapshot = await messagesRef.get();

        // Delete all messages
        for (DocumentSnapshot message in messagesSnapshot.docs) {
          await message.reference.delete();
        }

        // Finally, delete the chat document itself
        await _fireStore.collection("chats").doc(chatId).delete();

        informationBar(context, "Chat deleted successfully.");
      }
    } catch (e) {
      informationBar(context, "Couldn't delete chat: $e");
    }
  }

  //* update chat bg
  Future<String?> updateChatBackGroundImage(
      {required BuildContext context, required String chatId}) async {
    try {
      String? path = await _imageServices.pickImage();
      if (path != null) {
        String bgUrl = await _fireImageServices.uploadImageForChatBg(
            filePath: path, chatId: chatId, context: context);
        DocumentSnapshot docSnap =
            await _fireStore.collection("chats").doc(chatId).get();
        if (docSnap.exists) {
          Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
          DocumentReference docRef = _fireStore.collection("chats").doc(chatId);
          docRef.set({"bgUrl": bgUrl}, SetOptions(merge: true));
          if (data["bgUrl"] != null && data["bgUrl"] != "") {
            _fireImageServices.deleteImageFromFirebase(data["bgUrl"], context);
          }
          informationBar(context, "backGround Updated");
          return bgUrl;
        } else {
          informationBar(
              context, "Couldn't set BackGround image can't find chat");
          return null;
        }
      } else {
        return null;
      }
    } on FirebaseFirestore catch (e) {
      informationBar(context, "Couldn't set BackGround image $e");
      return null;
    }
  }

  //* get chat bg
  Future<String?> chatBg({required String chatId}) async {
    try {
      DocumentSnapshot chatData =
          await _fireStore.collection("chats").doc(chatId).get();
      if (chatData.exists) {
        Map<String, dynamic> data = chatData.data() as Map<String, dynamic>;
        if (data["bgUrl"] != null && data["bgUrl"] != "") {
          return data["bgUrl"];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //* block user in chat
  Future<void> blockUserInChat(
      {required BuildContext context,
      required String chatId,
      required bool isBlocked,
      required String otherUserId}) async {
    try {
      DocumentSnapshot chatData =
          await _fireStore.collection("chats").doc(chatId).get();
      if (chatData.exists) {
        DocumentReference chatRef =
            await _fireStore.collection("chats").doc(chatId);
        await chatRef.update({
          "blocked": isBlocked
              ? FieldValue.arrayRemove([otherUserId])
              : FieldValue.arrayUnion([otherUserId])
        });
      }
      informationBar(context, "User Blocked");
    } catch (e) {
      informationBar(context,
          "Bro too op can't be blocked! just joking here the error $e");
    }
  }

  //* check if blocked
  Future<bool?> isUserBlocked(
      {required String userId, required String chatId}) async {
    DocumentSnapshot docRef =
        await _fireStore.collection("chats").doc(chatId).get();
    if (docRef.exists) {
      Map<String, dynamic> data = docRef.data() as Map<String, dynamic>;
      return data["blocked"].contains(userId);
    } else {
      return null;
    }
  }

  //* get chat media
  Future<List<String>> fetchAllImageUrls(
      {required BuildContext context, required String chatId}) async {
    List<String> imageUrls = [];

    // try {
    // Reference to the messages sub-collection within a specific chat
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages");

    // Fetch all documents in the messages collection
    QuerySnapshot querySnapshot = await messagesRef.get();

    // Loop through each document in the collection
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Map<String,dynamic> data = doc.data() as Map<String,dynamic>;
      // Check if the 'imageUrl' field exists and is not null
      if (doc['imageUrl'] != null) {
        List<dynamic> dynamicList = doc['imageUrl'];
        List<String> imageUrlList = dynamicList.cast<String>();
        // Add the imageUrl to the list
        imageUrls.addAll(imageUrlList);
      }
    }
    // } catch (e) {
    //   print(e);
    //   informationBar(context, 'Error getting image URLs: $e');
    // }

    return imageUrls;
  }
}
