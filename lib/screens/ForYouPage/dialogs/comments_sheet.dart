import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/models/comment_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Chats/chats/image_view.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/comments_options.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/create_commen_sheet.dart';
import 'package:pintresto/services/comments_services.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/time_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/profile_image.dart';

class CommentsSheet extends StatefulWidget {
  int likeCounter;
  bool isLiked;
  final String postId;
  final PostModel post;
  CommentsSheet(
      {required this.isLiked,
      required this.likeCounter,
      required this.postId,
      required this.post,
      super.key});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  //* vars
  List<CommentModel> postComments = [];
  List<CommentModel> commentReplays = [];
  UserModel? user;
  int selectedReplies = 99999;

  int commentsLimit = 100;
  int replaysLimit = 100;
  //* controllers
  final TextEditingController _commentController = TextEditingController();
  //* instances
  final CommentsServices _commentsServices = CommentsServices();
  final UserServices _userServices = UserServices();
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());
  //* functions
  bool checkIfPostLiked() {
    return widget.isLiked;
  }

  //* like a comment by reacting
  void commentReactionManager(
      {required int index, required CommentModel comment}) {
    if (postComments[index].reactionsCount.contains(user!.userId)) {
      _commentsServices.likeComment(
        context: context,
        postId: widget.postId,
        ownerId: postComments[index].ownerId,
        commentId: comment.commentId,
        isAdd: false,
      );
      postComments[index].reactionsCount.remove(user!.userId);
    } else {
      _commentsServices.likeComment(
        context: context,
        postId: widget.postId,
        ownerId: postComments[index].ownerId,
        isAdd: true,
        commentId: comment.commentId,
      );
      postComments[index].reactionsCount.add(user!.userId);
    }
  }

  //* manage reaction states on replays
  void replayReactionManager(
      {required int replayIndex, required CommentModel comment}) {
    if (!commentReplays[replayIndex].reactionsCount.contains(user!.userId)) {
      _commentsServices.likeReplay(
          context: context,
          postId: widget.postId,
          ownerId: commentReplays[replayIndex].ownerId,
          commentId: comment.parentCommentId,
          isAdd: true,
          replayId: comment.commentId);
      commentReplays[replayIndex].reactionsCount.add(user!.userId);
    } else {
      _commentsServices.likeReplay(
        context: context,
        postId: widget.postId,
        ownerId: commentReplays[replayIndex].ownerId,
        replayId: comment.commentId,
        isAdd: false,
        commentId: comment.parentCommentId,
      );
      commentReplays[replayIndex].reactionsCount.remove(user!.userId);
    }
  }

  // get comments for the current post
  void getCommentsList() {
    _commentsServices
        .getComments(
            postId: widget.postId, limit: commentsLimit, context: context)
        .then((comments) {
      setState(() {
        postComments = comments;
      });
    });
  }

  // load replays for a specific comment
  void getReplaysForPost({required parentCommentId}) {
    _commentsServices
        .getReplays(
            postId: widget.postId,
            context: context,
            parentCommentId: parentCommentId,
            limit: replaysLimit)
        .then((replays) {
      setState(() {
        commentReplays = replays;
      });
    });
  }

  // check if comment is liked
  bool isLiked({required List<String> likes, required String userId}) {
    return likes.contains(user!.userId);
  }

  // apply change on ui
  void likeAndDislikeComment({required int index}) {
    setState(() {
      if (isLiked(
          likes: postComments[index].reactionsCount, userId: user!.userId)) {
        postComments[index].reactionsCount.remove(user!.userId);
      } else {
        postComments[index].reactionsCount.add(user!.userId);
      }
    });
  }

  //*
  @override
  void initState() {
    _userServices.getUserDetails(context).then((userData) {
      setState(() {
        user = userData;
      });
    });
    getCommentsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commentsSheetAppBar(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [commentSheetBody(), commentInput()],
      ),
    );
  }

  //* costume appBar
  PreferredSizeWidget commentsSheetAppBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    " ${postComments.length} Comments",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  TextButton(
                      onPressed: () {
                        if (checkIfPostLiked()) {
                          setState(() {
                            _postsServices.disLikePost(
                                context: context, postId: widget.postId);
                            widget.likeCounter -= 1;
                            widget.isLiked = !widget.isLiked;
                          });
                        } else {
                          setState(() {
                            _postsServices.likePost(
                                ownerId: widget.post.ownerId,
                                postId: widget.postId,
                                context: context);
                            widget.likeCounter += 1;
                            widget.isLiked = !widget.isLiked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            widget.likeCounter.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Icon(
                            checkIfPostLiked()
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          )
                        ],
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Divider(
                  color: Colors.grey.withOpacity(.3),
                  thickness: .5,
                ),
              ),
            ],
          ),
        ));
  }

  //* body builder
  Widget commentSheetBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: ListView.builder(
          itemCount: postComments.length,
          itemBuilder: (context, index) {
            return commentItem(
                comment: postComments[index], index: index, isReplay: false);
          }),
    );
  }

//* comment widget
  Widget commentItem(
      {required CommentModel comment,
      required int index,
      required isReplay,
      int replayIndex = 9999999}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: isReplay ? 2 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileWidget(
              imageUrl: comment.ownerPfp,
              userName: comment.ownerName ?? "U",
              size: 45),
          const SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.ownerName!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              //* content
              if (comment.isImage && comment.imageUrl != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImageView(url: comment.imageUrl!)));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                      image: NetworkImage(comment.imageUrl!),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 140,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey.withOpacity(.3)),
                          child: Center(
                            child: Text(
                              "(0u0!)",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        );
                      },
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (comment.content != null)
                Text(
                  comment.content!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
              //* action
              actionBar(
                  comment: comment,
                  index: index,
                  isReplay: isReplay,
                  replayIndex: replayIndex,
                  parentComment: comment.parentCommentId != ""
                      ? comment.parentCommentId
                      : comment.commentId,
                  likesCount: comment.reactionsCount,
                  timeStamp: comment.timeStamp,
                  replayCount: comment.replaysCount),
              //* replays
              replayWidgetBuilder(
                  replaysCount: comment.replaysCount,
                  showReplays: true,
                  commentIndex: index,
                  parentCommentId: comment.commentId,
                  replays: comment.replays)
            ],
          )
        ],
      ),
    );
  }

//* action bar
  Widget actionBar(
      {required Timestamp timeStamp,
      required List<String> likesCount,
      required CommentModel comment,
      String parentComment = "",
      int replayIndex = 0,
      required int index,
      required bool isReplay,
      required int replayCount}) {
    return Row(
      children: [
        Text(timeSince(timeStamp)),
        TextButton(
            onPressed: () {
              //* replay section command
              showCreateCommentBottomSheet(
                  context,
                  widget.postId,
                  user!.userId,
                  user!.userName,
                  user!.pfpUrl,
                  widget.post.ownerId,
                  true,
                  comment,
                  comment.commentId != ""
                      ? comment.commentId
                      : comment.parentCommentId,
                  (comment) {},
                  parentCommentId: comment.commentId != ""
                      ? comment.commentId
                      : comment.parentCommentId, (replay) {
                setState(() {
                  postComments[index].replays.insert(0, replay);
                  postComments[index].replaysCount += 1;
                });
              });
            },
            child: const Text("Reply")),
        TextButton(
            onPressed: () {
              setState(() {
                if (!isReplay) {
                  commentReactionManager(index: index, comment: comment);
                } else {
                  replayReactionManager(
                      replayIndex: replayIndex, comment: comment);
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  isLiked(likes: likesCount, userId: user!.userId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                if (likesCount.isNotEmpty) Text("  ${likesCount.length}")
              ],
            )),
        IconButton(
            onPressed: () {
              showCommentsOptionsBottomSheet(
                  context,
                  widget.postId,
                  widget.post.ownerId,
                  comment.ownerId,
                  comment.commentId,
                  comment.ownerName ?? "User",
                  isReplay,
                  parentComment, () {
                //* remove from user side ui
                setState(() {
                  getCommentsList();
                });
              });
            },
            icon: const Icon(Icons.more_horiz_outlined))
      ],
    );
  }

  //* replays widget builder
  Widget replayWidgetBuilder(
      {required int replaysCount,
      required bool showReplays,
      required int commentIndex,
      required String parentCommentId,
      required List<CommentModel> replays}) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          if (replaysCount > 0)
            GestureDetector(
                onTap: () {
                  setState(() {
                    _commentsServices
                        .getReplays(
                            context: context,
                            postId: widget.postId,
                            parentCommentId: parentCommentId,
                            limit: replaysLimit)
                        .then((replays) {
                      setState(() {
                        commentReplays = replays;
                        selectedReplies == commentIndex
                            ? selectedReplies = 999999
                            : selectedReplies = commentIndex;
                      });
                    });
                  });
                },
                child: Text(selectedReplies == commentIndex
                    ? "--- Hide Replays"
                    : "--- View $replaysCount reply")),
          if (selectedReplies == commentIndex && replaysCount > 0)
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 100,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: commentReplays.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2,
                      child: commentItem(
                          comment: commentReplays[index],
                          index: commentIndex,
                          replayIndex: index,
                          isReplay: true),
                    );
                  }),
            ),
          if (commentReplays.length == 100)
            GestureDetector(
              onTap: () {
                _commentsServices
                    .getReplays(
                        context: context,
                        postId: widget.postId,
                        parentCommentId: parentCommentId,
                        limit: replaysLimit + 100)
                    .then((replays) {
                  setState(() {
                    commentReplays = replays;
                  });
                });
              },
              child: const Text("Show more ..."),
            )
        ],
      );
    });
  }

  //* input filed
  Widget commentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          showCreateCommentBottomSheet(
              context,
              widget.postId,
              user!.userId,
              user!.userName,
              user!.pfpUrl,
              widget.post.ownerId,
              false,
              null,
              null, (comment) {
            setState(() {
              postComments.insert(0, comment);
            });
          }, (replay) {}, parentCommentId: null);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (user != null)
                profileWidget(
                    imageUrl: user!.pfpUrl, userName: user!.userName, size: 45),
              const SizedBox(
                width: 14,
              ),
              Flexible(
                child: costumeInputFiled(
                    hintText: "Add comment",
                    textController: _commentController,
                    trailing: trailingForInputFiled(),
                    horizontalPadding: 0,
                    verticalPadding: 4,
                    isActive: false),
              )
            ],
          ),
        ),
      ),
    );
  }

//* input field trailing
  Widget trailingForInputFiled() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.sticky_note_2_rounded,
              color: Theme.of(context).iconTheme.color,
            )),
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.image,
              color: Theme.of(context).iconTheme.color,
            )),
      ],
    );
  }
}

void commentsBottomSheet(BuildContext context, bool isLiked, int likeCounter,
    String postId, PostModel post) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 150),
          child: CommentsSheet(
            isLiked: isLiked,
            likeCounter: likeCounter,
            postId: postId,
            post: post,
          ),
        );
      });
}
