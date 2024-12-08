import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/models/comment_model.dart';
import 'package:pintresto/services/comments_services.dart';
import 'package:pintresto/services/image_picker.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

class CreateCommentSheet extends StatefulWidget {
  final String postId;
  final String userId;
  final String postOwnerId;
  final bool isReplay;
  final String userPfp;
  final String? commentId;
  final String? parentCommentId;
  final CommentModel? commentItem;
  final String userName;
  final void Function(CommentModel comment) onAddComment;
  final void Function(CommentModel replay) onAddReplay;
  const CreateCommentSheet(
      {required this.postId,
      required this.userId,
      required this.onAddReplay,
      required this.onAddComment,
      required this.userName,
      required this.postOwnerId,
      required this.userPfp,
      required this.isReplay,
      required this.commentId,
      this.commentItem,
      this.parentCommentId = "",
      super.key});

  @override
  State<CreateCommentSheet> createState() => _CreateCommentSheetState();
}

class _CreateCommentSheetState extends State<CreateCommentSheet> {
  //* vars
  String? imagePath;
  bool isImage = false;
  final CommentsServices _commentsServices = CommentsServices();
  //* controller
  final TextEditingController _commentController = TextEditingController();
  final int _maxLength = 500;

  //* functions
  void commentOnPost() {
    showLoadingDialog(context);
    //* place holder
    CommentModel comment = CommentModel(
        commentId: "",
        timeStamp: Timestamp.now(),
        ownerId: widget.userId,
        content: _commentController.text,
        reactionsCount: [],
        replays: [],
        isImage: isImage);
    _commentsServices
        .commentOnPost(
            postId: widget.postId,
            postOwnerId: widget.postOwnerId,
            comment: comment,
            isImage: isImage,
            imagePath: imagePath,
            context: context)
        .then((value) {
      comment.ownerName = widget.userName;
      comment.ownerPfp = widget.userPfp;
      comment.imageUrl = value["imageUrl"];
      comment.commentId = value["id"];
      widget.onAddComment(comment);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  //* replay on a comment
  void replayOnComments() {
    showLoadingDialog(context);
    CommentModel comment = CommentModel(
        commentId: "",
        timeStamp: Timestamp.now(),
        ownerId: widget.userId,
        content: _commentController.text,
        parentCommentId:
            (widget.commentItem != null && widget.commentItem!.isReplay)
                ? widget.commentItem!.parentCommentId
                : widget.parentCommentId!,
        reactionsCount: [],
        isReplay: true,
        replays: [],
        isImage: isImage);
    _commentsServices
        .replayOnComments(
            context: context,
            postId: widget.postId,
            parentCommentOwnerId: widget.commentItem!.ownerId,
            parentCommentId: comment.parentCommentId,
            isImage: isImage,
            replay: comment,
            imagePath: imagePath)
        .then((result) {
      comment.ownerName = widget.userName;
      comment.ownerPfp = widget.userPfp;
      comment.imageUrl = result["imageUrl"];
      comment.commentId = result["id"];
      widget.onAddReplay(comment);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Adjust padding for keyboard
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Makes bottom sheet adjust to content size
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
                const Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Add Comment",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
              ],
            ),
            if (imagePath != null) imageDisplay(imagePath: imagePath!),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _commentController,
                onChanged: (value) {
                  if (value.length > _maxLength) {
                    // Enforce character limit
                    _commentController.text = value.substring(0, _maxLength);
                    _commentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _maxLength),
                    );
                  } else {
                    setState(() {}); // Update UI with the current length
                  }
                },
                maxLines:
                    null, // Allows the text field to grow as the user types
                keyboardType: TextInputType.multiline,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      "Share what you like about this Pin, how it inspired you, or simply give a compliment",
                ),
              ),
            ),
            controlRow(),
          ],
        ),
      ),
    );
  }

  //* control row
  Widget controlRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    ImageServices().pickImage().then((path) {
                      setState(() {
                        isImage = true;
                        imagePath = path;
                      });
                    });
                  },
                  icon: const Icon(Icons.image)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.sticky_note_2)),
            ],
          ),
          Row(
            children: [
              Text(
                "${_commentController.text.length}/$_maxLength",
                style:
                    const TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
              ),
              const SizedBox(
                width: 16,
              ),
              SizedBox(
                width: 100,
                child: glowButtons(
                  title: "Post",
                  buttonColor:
                      _commentController.text.isEmpty && imagePath == null
                          ? Colors.grey.withOpacity(.7)
                          : Colors.red,
                  onClick: () {
                    // Post comment action
                    if (_commentController.text.isNotEmpty ||
                        imagePath != null) {
                      if (!widget.isReplay) {
                        commentOnPost();
                      } else {
                        replayOnComments();
                      }
                    }
                  },
                  horizontalPadding: 0,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  //* image display
  Widget imageDisplay({required String imagePath}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image(
          width: 100,
          height: 100,
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

void showCreateCommentBottomSheet(
    BuildContext context,
    String postId,
    String userId,
    String userName,
    String userPfp,
    String postOwnerId,
    bool isReplay,
    CommentModel? commentItem,
    String? commentId,
    void Function(CommentModel comment) onAddComment,
    void Function(CommentModel replay) onAddReplay,
    {required String? parentCommentId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Allows the bottom sheet to expand when the keyboard is shown
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ), // Add top border radius
    builder: (context) {
      return CreateCommentSheet(
        postId: postId,
        commentId: commentId,
        userId: userId,
        postOwnerId: postOwnerId,
        isReplay: isReplay,
        parentCommentId: parentCommentId,
        onAddReplay: onAddReplay,
        commentItem: commentItem,
        onAddComment: onAddComment,
        userName: userName,
        userPfp: userPfp,
      );
    },
  );
}
