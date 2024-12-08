import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/services/comments_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/option_button.dart';

class CommentsOptions extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String commentOwnerId;
  final String commentId;
  final String commentOwnerName;
  final bool isReply; // New property
  final String? parentCommentId; // New property
  final VoidCallback onDelete; // New property for delete callback

  const CommentsOptions(
      {required this.commentId,
      required this.postId,
      required this.postOwnerId,
      required this.commentOwnerId,
      required this.commentOwnerName,
      required this.isReply, // New parameter
      this.parentCommentId, // New parameter
      required this.onDelete, // New parameter
      super.key});

  @override
  State<CommentsOptions> createState() => _CommentsOptionsState();
}

class _CommentsOptionsState extends State<CommentsOptions> {
  //* vars
  String? user;

  //* instances
  CommentsServices _commentsServices = CommentsServices();
  UserServices _userServices = UserServices();

  //* functions
  bool canDelete() {
    return user == widget.commentOwnerId || user == widget.postOwnerId;
  }

  //* init
  @override
  void initState() {
    user = _userServices.getCurrentUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canDelete())
          optionText(
              text: "Remove Comment",
              icon: IconPack.trash,
              onClick: () {
                showLoadingDialog(context);
                if (widget.isReply) {
                  _commentsServices
                      .removeReplayFromPost(
                          context: context,
                          postId: widget.postId,
                          commentId: widget.parentCommentId!,
                          replayId: widget.commentId)
                      .then((_) {
                        widget.onDelete();
                        Navigator.pop(context);
                      });
                } else {
                  _commentsServices
                      .removeCommentFromPost(
                          context: context,
                          postId: widget.postId,
                          commentId: widget.commentId)
                      .then((_) {
                        widget.onDelete();
                        Navigator.pop(context);
                      });
                }
              }),
        optionText(
            text: "Report ${widget.commentOwnerName}",
            icon: Icons.person_2_rounded,
            onClick: () {}),
        optionText(
            text: "Block ${widget.commentOwnerName}",
            icon: Icons.info,
            onClick: () {}),
      ],
    );
  }
}

void showCommentsOptionsBottomSheet(
    BuildContext context,
    String postId,
    String postOwnerId,
    String commentOwnerId,
    String commentId,
    String commentOwnerName,
    bool isReply, // New parameter
    String? parentCommentId,
    VoidCallback onDelete) {
  // New parameter for delete callback
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return CommentsOptions(
        postId: postId,
        postOwnerId: postOwnerId,
        commentOwnerId: commentOwnerId,
        commentId: commentId,
        commentOwnerName: commentOwnerName,
        isReply: isReply, // Pass the new parameter
        parentCommentId: parentCommentId, // Pass the new parameter
        onDelete: onDelete, // Pass the new parameter
      );
    },
  );
}
