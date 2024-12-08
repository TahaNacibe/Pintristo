import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/image_services.dart';
import 'package:pintresto/services/updater.dart';
import 'package:pintresto/services/user_services.dart';

class PostsServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FireImageServices _imageServices = FireImageServices();
  final Updater _updater = Updater();
  UserServices userServices = UserServices();
  final BoardServices _boardServices = BoardServices();
  final NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());

  PostsServices({required this.userServices});

  //* create a post
  Future<void> postPin(
      {required PostModel post, required BuildContext context}) async {
    try {
      //* upload the image and return the url
      String imageUrl = await _imageServices.uploadImageIntoStorage(
          imagePath: post.imageUrl, context: context);
      //* update the path as place holder by the actual url
      post.imageUrl = imageUrl;
      post.ownerId = _auth.currentUser!.uid;
      //* create the actual post
      await createAPin(post: post, context: context);
      //* update the tags counter
      updateUsedTagsCounters(selectedTags: post.selectedTags);
      informationBar(context, "Post Created");
    } catch (e) {
      //* on error case
      informationBar(context, "Error:$e");
    }
  }

  //* tags counter update
  Future<void> updateUsedTagsCounters(
      {required List<String> selectedTags}) async {
    try {
      for (String tagName in selectedTags) {
        DocumentSnapshot tagSnap =
            await _firestore.collection("tags").doc(tagName).get();
        if (tagSnap.exists) {
          DocumentReference docRef = _firestore.collection("tags").doc(tagName);
          await docRef.update({"used": FieldValue.increment(1)});
        }
      }
    } catch (e) {}
  }

  //* create the final pin object
  Future<void> createAPin(
      {required PostModel post, required BuildContext context}) async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentReference docRef = _firestore.collection("Pins").doc();
      // Set data to the document
      await docRef.set(post.toJson());
      // Get the auto-generated document ID
      String newDocId = docRef.id;
      // update
      await docRef.update({"postId": newDocId});
      // update user data
      _updater.updateListField(
          context: context,
          userId: userId,
          fieldName: "userPins",
          item: newDocId,
          isAdd: true,
          collection: "users");
      //* update the board filed
      if (post.boardId != null) {
        _updater.updateListField(
            context: context,
            userId: post.boardId!,
            fieldName: "postsIds",
            item: newDocId,
            isAdd: true,
            collection: "boards");
        //* update the board cover
        _boardServices.updateTheBoardCover(
            coverUrl: post.imageUrl, boardId: post.boardId!, context: context);
      }
    } catch (e) {
      informationBar(context, "Error:$e");
    }
  }

  //* get post by it's id
  Future<PostModel?> getPostById(
      {required String? postId, required BuildContext context}) async {
    try {
      if (postId != null) {
        DocumentSnapshot docRef =
            await _firestore.collection("Pins").doc(postId).get();
        if (docRef.exists) {
          Map<String, dynamic> jsonData = docRef.data() as Map<String, dynamic>;
          return PostModel.fromJson(jsonData);
        }
        return null;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      informationBar(context, "Error:$e");
      return null;
    }
  }

  //* like a post
  Future<void> likePost(
      {required String postId,
      required String ownerId,
      required BuildContext context}) async {
    try {
      //* applying like
      _updater.updateListField(
          context: context,
          userId: _auth.currentUser!.uid,
          fieldName: "likedPosts",
          item: postId,
          collection: "users",
          isAdd: true);
      await _firestore
          .collection("Pins")
          .doc(postId)
          .update({"likes": FieldValue.increment(1)});
      //* sent notification to use
      _notificationsServices.sendNotificationForLikeAPost(
          receiverId: ownerId, context: context, postId: postId);
    } on FirebaseException catch (e) {
      informationBar(context, "Error: couldn't Like the Post ${e.code}");
    }
  }

  //* dislike a post
  Future<void> disLikePost(
      {required String postId, required BuildContext context}) async {
    try {
      _updater.updateListField(
          context: context,
          userId: _auth.currentUser!.uid,
          fieldName: "likedPosts",
          item: postId,
          collection: "users",
          isAdd: true);
      await _firestore
          .collection("Pins")
          .doc(postId)
          .update({"likes": FieldValue.increment(-1)});
    } on FirebaseException catch (e) {
      informationBar(context, "Error: couldn't dislike a Post ${e.code}");
    }
  }

  //* get the more like under the post
  Future<List<PostModel>> getPostsWithTagsAndTitle({
    required List<String> tags,
    required String postIdToIgnore, // Add postIdToIgnore as a parameter
    required BuildContext context,
  }) async {
    try {
      List<Map<String, dynamic>> allPosts = [];

      // Step 1: Query posts where 'selectedTags' contains at least one tag
      QuerySnapshot querySnapshotWithTags = await _firestore
          .collection("Pins")
          .where('selectedTags', arrayContainsAny: tags)
          .get();
      // Step 2: For each post, fetch the owner's details from the 'users' collection
      for (var doc in querySnapshotWithTags.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        // Get the current postId
        String postId = postData['postId'] ?? '';
        // Ignore the post with the specific postId (if it matches postIdToIgnore)
        if (postId == postIdToIgnore) {
          continue; // Skip this iteration
        }
        // Extract the ownerId from the post
        String ownerId = postData['ownerId'] ?? '';

        // Fetch the corresponding user document using ownerId
        if (ownerId.isNotEmpty) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection("users")
              .doc(ownerId)
              .get();

          if (userSnapshot.exists) {
            // Get ownerName and ownerPfp from the user document
            String ownerName = userSnapshot['userName'] ?? '';
            String ownerPfp = userSnapshot['pfpUrl'] ?? '';

            // Add ownerName and ownerPfp to the post data
            postData['ownerName'] = ownerName;
            postData['ownerPfp'] = ownerPfp;
          }
        }

        // Add the post to the list after updating with owner info
        allPosts.add(postData);
      }

      // Map post data to PostModel and return the list
      return allPosts.map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      // informationBar(context, "Error fetching posts: $e");
      return [];
    }
  }

  //* get the more like under the post
  Future<List<PostModel>> getPostsForBoardType({
    required BoardModel board, // Add postIdToIgnore as a parameter
    required BuildContext context,
  }) async {
    try {
      List<PostModel> posts = [];
      for (String id in board.postsIds) {
        PostModel? post = await getPostById(postId: id, context: context);
        if (post != null) {
          posts.add(post);
        }
      }
      List<dynamic> tags = posts
          .expand((post) =>
              post.selectedTags) // Assuming post.tags is a List<String>
          .toList();
      if (tags.isEmpty) {
        return [];
      }
      List<Map<String, dynamic>> allPosts = [];

      // Step 1: Query posts where 'selectedTags' contains at least one tag
      QuerySnapshot querySnapshotWithTags = await _firestore
          .collection("Pins")
          .where('selectedTags', arrayContainsAny: tags)
          .get();
      // Step 2: For each post, fetch the owner's details from the 'users' collection
      for (var doc in querySnapshotWithTags.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        // Extract the ownerId from the post
        String ownerId = postData['ownerId'] ?? '';

        // Fetch the corresponding user document using ownerId
        if (ownerId.isNotEmpty) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection("users")
              .doc(ownerId)
              .get();

          if (userSnapshot.exists) {
            // Get ownerName and ownerPfp from the user document
            String ownerName = userSnapshot['userName'] ?? '';
            String ownerPfp = userSnapshot['pfpUrl'] ?? '';

            // Add ownerName and ownerPfp to the post data
            postData['ownerName'] = ownerName;
            postData['ownerPfp'] = ownerPfp;
          }
        }

        // Add the post to the list after updating with owner info
        allPosts.add(postData);
      }

      // Map post data to PostModel and return the list
      return allPosts.map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      // informationBar(context, "Error fetching posts: $e");
      return [];
    }
  }

  //* change favorite state for posts in profile details
  Future<void> setPinAsFavorite(
      {required String postId,
      required bool isFavorite,
      required BuildContext context}) async {
    _updater.updateListField(
        context: context,
        userId: _auth.currentUser!.uid,
        fieldName: "favorites",
        item: postId,
        collection: "users",
        isAdd: isFavorite);
  }

  //* update Pins data
  Future<List<PostModel>> updatePostsData(
      {required List<PostModel> posts, required BuildContext context}) async {
    try {
      List<PostModel> editedData = [];
      for (PostModel post in posts) {
        UserModel? userDetails = await userServices.getOtherUserDetails(
            userId: post.ownerId, context: context);
        if (userDetails != null) {
          post.ownerName = userDetails.userName;
          post.ownerPfp = userDetails.pfpUrl;
        }
        editedData.add(post);
      }
      return editedData;
    } catch (e) {
      informationBar(context, "Error:$e");
      return [];
    }
  }

  //* save a pin to your saved list
  Future<void> savePost(
      {required String postId,
      required bool actionType,
      required BuildContext context}) async {
    _updater.updateListField(
        context: context,
        userId: _auth.currentUser!.uid,
        fieldName: "savedPins",
        item: postId,
        collection: "users",
        isAdd: actionType);
  }

  //* delete post
  Future<void> deleteUserPost(
      {required String postId, required BuildContext context}) async {
    try {
      DocumentSnapshot docSnap =
          await _firestore.collection("Pins").doc(postId).get();
      //* check if exist
      if (docSnap.exists) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        //* get post
        DocumentReference docRef = _firestore.collection("Pins").doc(postId);
        //* get post board
        DocumentReference boardRef =
            _firestore.collection("boards").doc(data["boardId"]);
        //* remove post of board
        boardRef.update({
          "postsIds": FieldValue.arrayRemove([postId])
        });
        //* remove post
        await docRef.delete();
        informationBar(context, "Pin deleted");
      }
    } on FirebaseException catch (e) {
      informationBar(context, "couldn't delete $e");
    }
  }
}
