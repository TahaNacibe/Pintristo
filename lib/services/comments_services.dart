import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/comment_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/services/image_services.dart';
import 'package:pintresto/services/user_services.dart';

class CommentsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();
  final FireImageServices _imageServices = FireImageServices();
  final NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());

  String getCurrentUserId() {
    String userId = _authServices.getTheCurrentUserId();
    return userId;
  }

  //* send a comment
  Future<Map<String, dynamic>> commentOnPost(
      {required String postId,
      required CommentModel comment,
      required String postOwnerId,
      required isImage,
      required BuildContext context,
      String? imagePath = ""}) async {
    try {
      String imageUrl = "";
      comment.ownerId = getCurrentUserId();
      DocumentReference docRef = _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc();
      await docRef.set(comment.toJson());
      if (isImage) {
        imageUrl = await _imageServices.uploadCommentImage(
            context: context, filePath: imagePath!, userId: getCurrentUserId());
      }
      String commentId = docRef.id;
      await docRef.update({
        "commentId": commentId,
        "imageUrl": imageUrl,
      });
      informationBar(context, "Comment Posted");
      _notificationsServices.sendNotificationForCommenting(
        receiverId: postOwnerId,
        postId: postId,
        context: context,
        comment: comment.content ?? "Image",
      );
      return {"imageUrl": imageUrl, "id": commentId};
    } catch (e) {
      informationBar(context, "Failed to Comment $e");
      return {"imageUrl": "imageUrl", "id": "commentId"};
    }
  }

  //* send a replay
  Future<Map<String, dynamic>> replayOnComments(
      {required String postId,
      required String parentCommentId,
      required String parentCommentOwnerId,
      required bool isImage,
      required BuildContext context,
      String? imagePath = "",
      required CommentModel replay}) async {
    //* the real comment process
    try {
      String imageUrl = "";
      replay.ownerId = getCurrentUserId();
      DocumentReference docRef = _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(parentCommentId)
          .collection("replays")
          .doc();
      await docRef.set(replay.toJson(), SetOptions(merge: true));
      if (isImage) {
        imageUrl = await _imageServices.uploadCommentImage(
            context: context, filePath: imagePath!, userId: getCurrentUserId());
      }
      String commentId = docRef.id;
      await docRef.update({
        "commentId": commentId,
        "imageUrl": imageUrl,
      });
      //* update the comment values
      DocumentReference comRef = _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(parentCommentId);
      await comRef.update({"replaysCount": FieldValue.increment(1)});
      informationBar(context, "Replay Posted");
      _notificationsServices.sendNotificationForReplaying(
          receiverId: parentCommentOwnerId,
          postId: postId,
          comment: replay.content ?? "Image",
          context: context);
      return {"imageUrl": imageUrl, "id": commentId};
    } catch (e) {
      informationBar(context, "Failed to post replay $e");
      return {"imageUrl": "imageUrl", "id": "commentId"};
    }
  }

  //* like a comment and replay
  Future<void> likeComment(
      {required String postId,
      required String commentId,
      required String ownerId,
      required bool isAdd,
      required BuildContext context}) async {
    try {
      DocumentReference docRef = _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(commentId);
      await docRef.update({
        "reactionsCount": isAdd
            ? FieldValue.arrayUnion([getCurrentUserId()])
            : FieldValue.arrayRemove([getCurrentUserId()])
      });
      _notificationsServices.sendNotificationForReactingOnComment(
          postId: postId, receiverId: ownerId, context: context);
    } catch (e) {
      informationBar(context, "Something went wrong $e");
    }
  }

  //* like a comment and replay
  Future<void> likeReplay(
      {required String postId,
      required String commentId,
      required String ownerId,
      required bool isAdd,
      required BuildContext context,
      required String replayId}) async {
    try {
      DocumentReference docRef = _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replays")
          .doc(replayId);
      await docRef.update({
        "reactionsCount": isAdd
            ? FieldValue.arrayUnion([getCurrentUserId()])
            : FieldValue.arrayRemove([getCurrentUserId()])
      });
      _notificationsServices.sendNotificationForReactingOnComment(
          postId: postId, receiverId: ownerId, context: context);
    } catch (e) {
      informationBar(context, "Something went wrong $e");
    }
  }

  //* get post comments
  Future<List<CommentModel>> getComments(
      {required String postId,
      required int limit,
      required BuildContext context}) async {
    List<CommentModel> postComments = [];
    try {
      // Query to get comments ordered by 'timeStamp'
      QuerySnapshot querySnapshot = await _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .orderBy("timeStamp", descending: true)
          .limit(limit)
          // descending will show latest comments first
          .get();

      // Processing the fetched comments
      for (var doc in querySnapshot.docs) {
        // Each doc represents a comment
        Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
        // Fetch user data based on ownerId
        String ownerId = commentData['ownerId'];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(ownerId)
            .get();
        // Get ownerName and ownerPfp from user document
        String ownerName = userSnapshot['userName'];
        String ownerPfp = userSnapshot['pfpUrl'];

        // Access the fields in the comment, e.g.:
        CommentModel comment = CommentModel.fromJson(
          commentData,
          ownerName: ownerName,
          ownerPfp: ownerPfp,
        );
        postComments.add(comment);
        // Do something with the comment data
      }
      return postComments;
    } catch (e) {
      informationBar(context, 'Error fetching comments: $e');
      return postComments;
    }
  }

  //* get comments replays
  Future<List<CommentModel>> getReplays(
      {required String postId,
      required String parentCommentId,
      required BuildContext context,
      required int limit}) async {
    List<CommentModel> commentReplays = [];
    try {
      // Query to get comments ordered by 'timeStamp'
      QuerySnapshot querySnapshot = await _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(parentCommentId)
          .collection("replays")
          .orderBy("timeStamp", descending: true)
          .limit(limit) // descending will show latest comments first
          .get();

      // Processing the fetched comments
      for (var doc in querySnapshot.docs) {
        // Each doc represents a comment
        Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
        String ownerId = commentData['ownerId'];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(ownerId)
            .get();
        // Get ownerName and ownerPfp from user document
        String ownerName = userSnapshot['userName'];
        String ownerPfp = userSnapshot['pfpUrl'];

        // Access the fields in the comment, e.g.:
        CommentModel comment = CommentModel.fromJson(
          commentData,
          ownerName: ownerName,
          ownerPfp: ownerPfp,
        );
        commentReplays.add(comment);
        // Do something with the comment data
      }
      return commentReplays;
    } catch (e) {
      informationBar(context, 'Error fetching comments: $e');
      return commentReplays;
    }
  }

  //* delete a comment
  Future<void> removeCommentFromPost(
      {required BuildContext context,
      required String postId,
      required String commentId}) async {
    try {
      DocumentSnapshot commentSnap = await _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .get();
      if (commentSnap.exists) {
        DocumentReference docRef = _firestore
            .collection("Pins")
            .doc(postId)
            .collection("comments")
            .doc(commentId);
        docRef.delete();
        informationBar(context, "Comment removed");
      }
    } catch (e) {
      informationBar(context, "Failed to remove comment $e");
    }
  }

  //* delete a replay
  Future<void> removeReplayFromPost(
      {required BuildContext context,
      required String postId,
      required String commentId,
      required String replayId}) async {
    try {
      DocumentSnapshot commentSnap = await _firestore
          .collection("Pins")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replays")
          .doc(replayId)
          .get();
      if (commentSnap.exists) {
        DocumentReference docRef = _firestore
            .collection("Pins")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("replays")
            .doc(replayId);
        docRef.delete();
        DocumentReference comRef = _firestore
            .collection("Pins")
            .doc(postId)
            .collection("comments")
            .doc(commentId);
        comRef.update({"replaysCount": FieldValue.increment(-1)});
        informationBar(context, "Replay removed");
      }
    } catch (e) {
      informationBar(context, "Failed to remove Replay $e");
    }
  }
}
