import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/services/updater.dart';

class BoardServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Updater _updater = Updater();

  //* create boards from user
  Future<String?> createBoardInDataBase(
      {required String userId,
      required String boardName,
      required BuildContext context,
      required List<String> contributes,
      required bool isSecret}) async {
    // board model initialize
    BoardModel boardItem = BoardModel(
        name: boardName,
        isSecret: isSecret,
        postsIds: [],
        contributors: contributes,
        boardId: "",
        cover: "");
    // upload to firestore
    try {
      // upload the board into the board collection
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef = _firestore.collection('boards').doc();

// Set data to the document
      await docRef.set(boardItem.toJson());

// Get the auto-generated document ID
      String newDocId = docRef.id;
      // update
      await docRef.update({"boardId": newDocId});
      addContractures(ids: contributes, board: newDocId, context: context);
      // update user data
      _updater.updateListField(
          userId: userId,
          fieldName: "yourBoards",
          context: context,
          item: newDocId,
          isAdd: true,
          collection: "users");
      // return the board id
      return newDocId;
    } catch (e) {
      informationBar(context, 'Failed to create board: $e');
      // return null
      return null;
    }
  }

  //* get user boards
  Future<List<BoardModel>> userBoards(
      {required String userId,
      required bool isUser,
      required BuildContext context}) async {
    //* place holders
    List<BoardModel> userBoards = [];
    //* firestore service
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        //* get each board by id
        for (String boardId in userDoc["yourBoards"]) {
          DocumentSnapshot boardDoc =
              await _firestore.collection("boards").doc(boardId).get();
          if (boardDoc.exists) {
            //* turn to json and add to list
            Map<String, dynamic> boardJson =
                boardDoc.data() as Map<String, dynamic>;
            userBoards.add(BoardModel.fromJson(boardJson));
          }
        }
        //* return to list
        return userBoards.toList();
      } else {
        return [];
      }
    } catch (e) {
      informationBar(context, "Failed to get user boards $e");
      //* return empty list
      return [];
    }
  }

  //* update the board cover
  Future<void> updateTheBoardCover(
      {required String coverUrl,
      required String boardId,
      required BuildContext context}) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('boards').doc(boardId).get();
      if (userDoc.exists) {
        await _firestore
            .collection('boards')
            .doc(boardId)
            .update({"cover": coverUrl});
      }
    } on FirebaseFirestore catch (e) {
      informationBar(context, "Failed to update Board cover $e");
    }
  }

  //* remove items from board
  Future<void> handleRemovingItemsFromBoards(
      {required String boardId,
      required List<String> selectedIds,
      required String lastPostImageUrl,
      required BuildContext context}) async {
    try {
      DocumentReference docRef = _firestore.collection("boards").doc(boardId);
      docRef.update({
        "imageUrl": lastPostImageUrl,
        "postsIds": FieldValue.arrayRemove(selectedIds)
      });
    } catch (e) {
      informationBar(context, "Failed to remove item from board $e");
    }
  }

  //* create a board a user
  Future<void> addContractures(
      {required List<String> ids,
      required String board,
      required BuildContext context}) async {
    try {
      for (String id in ids) {
        DocumentReference docRef = _firestore.collection("users").doc(id);
        await docRef.update({
          "yourBoards": FieldValue.arrayUnion([board])
        });
      }
    } catch (e) {
      informationBar(context, "Failed to add Contractures $e");
    }
  }

//* Change board visibility
  Future<void> changeBoardVisibility(
      {required BuildContext context, required String boardId}) async {
    try {
      // Reference to the document in Firestore
      DocumentReference docRef = _firestore.collection("boards").doc(boardId);
      // Perform a transaction to ensure atomic read-modify-write operation
      await _firestore.runTransaction((transaction) async {
        // Get the document snapshot
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("Board does not exist!");
        }
        // Get the current value of 'isSecret'
        bool isSecret = snapshot.get('isSecret');
        // Reverse the boolean value
        bool newVisibility = !isSecret;
        // Update the document with the new 'isSecret' value
        transaction.update(docRef, {"isSecret": newVisibility});
      });
      // Show a success message after the update
      informationBar(context, "Board visibility changed!");
    } catch (e) {
      // Handle errors and show failure message
      informationBar(context, "Failed to change board visibility: $e");
    }
  }

  //* delete a board
  Future<void> deleteBoard(
      {required BuildContext context,
      required String boardId,
      required String userId}) async {
    try {
      DocumentSnapshot docSnap =
          await _firestore.collection("boards").doc(boardId).get();
      //* check if exist
      if (docSnap.exists) {
        //* get post
        DocumentReference docRef = _firestore.collection("boards").doc(boardId);
        //* get post board
        DocumentReference userDoc = _firestore.collection("users").doc(userId);
        //* remove post of board
        await userDoc.update({
          "yourBoards": FieldValue.arrayRemove([boardId])
        });
        //* remove post
        await docRef.delete();
        informationBar(context, "board deleted");
      }
    } on FirebaseException catch (e) {
      informationBar(context, "couldn't delete board $e");
    }
  }

  //* add pin to board
  Future<void> addPinToBoard(
      {required BuildContext context,
      required String boardId,
      required List<String> pinsIds}) async {
    try {
      DocumentSnapshot docSnap =
          await _firestore.collection("boards").doc(boardId).get();
      //* check if exist
      if (docSnap.exists) {
        //* update board
        DocumentReference docRef = _firestore.collection("boards").doc(boardId);
        await docRef.update({"postsIds": FieldValue.arrayUnion(pinsIds)});
        for (String id in pinsIds) {
          DocumentReference pinDoc = _firestore.collection("Pins").doc(id);
          //* remove post of board
          pinDoc.update({"boardId": boardId});
          //* update the cover image
          DocumentSnapshot PostSnap =
              await _firestore.collection("Pins").doc(pinsIds.last).get();
          if (PostSnap.exists) {
            Map<String, dynamic> data = PostSnap.data() as Map<String, dynamic>;
            docRef.update({"cover": data["imageUrl"]});
          }
        }
        informationBar(context, "${pinsIds.length} Pin were added");
      }
    } on FirebaseException catch (e) {
      informationBar(context, "couldn't add Pins $e");
    }
  }
}
