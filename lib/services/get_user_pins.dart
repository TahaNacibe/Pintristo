import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';

class GetUserPins {
  final BoardServices _boardServices = BoardServices();
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());
  final AuthServices _authServices = AuthServices();
  final UserServices _userServices = UserServices();
  Future<Map<String, dynamic>> getUserPins(
      {required String userId, required BuildContext context}) async {
    //* Initialize result map
    Map<String, List<PostModel>> postsList = {
      "created": [],
      "saved": [],
      "inBoard": []
    };
    try {
      //* Get user details
      UserModel? user =
          await _userServices.getOtherUserDetails(userId: userId, context: context);
      if (user == null) {
        return postsList; // Return early if the user is null
      }

      //* Collect created, saved, and board pins
      List<String> createdIds = user.userPins;
      List<String> savedPins = user.savedPins;

      // Collect board pins
      List<BoardModel> boards = await _boardServices.userBoards(
          context: context,
          userId: userId,
          isUser: _authServices.checkIfItsUser(userId: userId));
      List<String> boardsPins =
          boards.expand((board) => board.postsIds).toList();

      //* Fetch posts concurrently using Future.wait
      List<Future<PostModel?>> createdPostsFutures = createdIds
          .map((id) => _postsServices.getPostById(postId: id, context: context))
          .toList();
      List<Future<PostModel?>> savedPostsFutures = savedPins
          .map((id) => _postsServices.getPostById(postId: id, context: context))
          .toList();
      List<Future<PostModel?>> boardPostsFutures = boardsPins
          .map((id) => _postsServices.getPostById(postId: id, context: context))
          .toList();

      //* Resolve all futures concurrently
      List<PostModel?> createdPosts = await Future.wait(createdPostsFutures);
      List<PostModel?> savedPosts = await Future.wait(savedPostsFutures);
      List<PostModel?> boardPosts = await Future.wait(boardPostsFutures);

      //* Filter out null posts and add to result map
      postsList["created"]!.addAll(createdPosts.whereType<PostModel>());
      postsList["saved"]!.addAll(savedPosts.whereType<PostModel>());
      postsList["inBoard"]!.addAll(boardPosts.whereType<PostModel>());

      return postsList;
    } catch (e) {
      informationBar(context, "Failed to get user Pins $e");
      return {};
    }
  }
}
