import 'package:flutter/material.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/comments_sheet.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/pins_options.dart';
import 'package:pintresto/screens/ForYouPage/widget/follow_button.dart';
import 'package:pintresto/screens/ForYouPage/widget/post_informations.dart';
import 'package:pintresto/screens/ForYouPage/widget/similar_items_page.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/error_future.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:pintresto/widgets/rounded_button.dart';

class PinScreen extends StatefulWidget {
  final PostModel post;
  final void Function(String postId) deleteAction;
  final bool showBottomSheet;
  const PinScreen(
      {required this.post,
      this.showBottomSheet = false,
      required this.deleteAction,
      super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  bool isLoading = true;
  //* vars
  UserModel? currentUser;
  UserModel? postOwner;
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());
  final UserServices _userServices = UserServices();
  //* controller
  final TextEditingController _commentController = TextEditingController();
  //*
  @override
  void initState() {
    _userServices
        .getPostOwner(id: widget.post.ownerId, context: context)
        .then((value) {
      setState(() {
        widget.post.ownerPfp = value!.pfpUrl;
        widget.post.ownerName = value.userName;
        postOwner = value;
        isLoading = false;
      });
      openCommentSheetIfNeeded();
    });
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        currentUser = user;
      });
    });
    super.initState();
  }

  //* functions
  bool checkIfPostLiked() {
    if (currentUser != null && currentUser!.likedPosts.isNotEmpty) {
      return currentUser!.likedPosts.contains(widget.post.postId);
    } else {
      return false;
    }
  }

  void openCommentSheetIfNeeded() {
    if (widget.showBottomSheet) {
      commentsBottomSheet(context, checkIfPostLiked(), widget.post.likes,
          widget.post.postId, widget.post);
    }
  }

  // check if user is following that creator
  bool checkIfUserIsFollowing() {
    if (currentUser != null && currentUser!.followingIds.isNotEmpty) {
      return currentUser!.followingIds.contains(widget.post.ownerId);
    } else {
      return false;
    }
  }

  bool checkIfPostIsSaved({required String postId}) {
    return currentUser!.savedPins.contains(postId);
  }

  void saveOrRemoveSave({required String postId}) {
    setState(() {
      if (currentUser!.savedPins.contains(postId)) {
        currentUser!.savedPins.remove(postId);
        _postsServices.savePost(
            postId: postId, context: context, actionType: false);
      } else {
        currentUser!.savedPins.add(postId);
        _postsServices.savePost(
            postId: postId, context: context, actionType: true);
      }
    });
  }

  void changeFollowState() {
    if (checkIfUserIsFollowing()) {
      //* unFollow
      setState(() {
        _userServices.unFollowUser(
            context: context, followedUserId: widget.post.ownerId);
        currentUser!.followingIds.remove(widget.post.ownerId);
        widget.post.followers -= 1;
      });
    } else {
      //* follow
      setState(() {
        _userServices.followUser(
            context: context, followedUserId: widget.post.ownerId);
        currentUser!.followingIds.add(widget.post.ownerId);
        widget.post.followers += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [isLoading ? loadingWidgetBody() : pinBody()],
        ),
      )),
    );
  }

  //* loading widget
  Widget loadingWidgetBody() {
    return SizedBox(height: 400, child: Center(child: loadingWidget()));
  }

  //* pin body
  Widget pinBody() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pinScreenBody(),
            information(),
            //* post details
            postDetailsSection(),
            otherOptions(),
            widget.post.allowComments
                ? commentsSection()
                : errorWidget(text: "Owner turned off comments for that post"),
            SimilarItemsPage(
              tags: widget.post.selectedTags,
              postId: widget.post.postId,
              postServices: _postsServices,
            )
          ],
        ),
        imageActionButton(),
      ],
    );
  }

  //* information
  Widget information() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //* owner info
          ownerInfo(),
          //* follow button
          FollowButton(
              isFollowed: checkIfUserIsFollowing(), onClick: changeFollowState)
        ],
      ),
    );
  }

  //* userData
  Widget ownerInfo() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            isCurrentUser: false,
                            userId: widget.post.ownerId,
                          )));
            },
            child: profileWidget(
                imageUrl: widget.post.ownerPfp,
                userName: widget.post.ownerName,
                size: 45),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.ownerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  "${postOwner!.followersIds.length} Followers",
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  //* post details widget
  Widget postDetailsSection() {
    return PostInformation(
        title: widget.post.title, desc: widget.post.description);
  }

  //* item display
  Widget itemDisplay() {
    return Stack(
      children: [
        Image(
          image: NetworkImage(widget.post.imageUrl),
          width: MediaQuery.sizeOf(context).width,
          fit: BoxFit.cover,
        ),
        Container(
          height: 80,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [
                .3,
                1
              ],
                  colors: [
                Theme.of(context).scaffoldBackgroundColor.withOpacity(.1),
                Colors.transparent
              ])),
        )
      ],
    );
  }

  //* widget body
  Widget pinScreenBody() {
    return Stack(
      children: [
        itemDisplay(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //* app bar
              costumeAppBar(),
            ],
          ),
        ),
      ],
    );
  }

//* appBar costume item
  Widget costumeAppBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: roundedButton(
                  icon: Icons.arrow_back_ios_new_rounded, padding: 6)),
          GestureDetector(
              onTap: () {
                //* show options
                showOptionsForPins(
                    context, widget.post, currentUser!.userId, _postsServices,
                    () {
                  //ToDo: update old list
                  widget.deleteAction(widget.post.postId);
                });
              },
              child:
                  roundedButton(icon: Icons.more_horiz_outlined, padding: 6)),
        ],
      ),
    );
  }

  //* actions buttons widget
  Widget actionsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //* search by image
        costumeButtonWidget(icon: Icons.image_search, onTap: () {}),
        //* edit button
        costumeButtonWidget(icon: Icons.cut_outlined, onTap: () {}),
      ],
    );
  }

  //* costume rounded button
  Widget costumeButtonWidget(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.7)),
          child: Icon(icon),
        ),
      ),
    );
  }

  //* i couldn't make the button go on top of that stupid thing so here the solution i got at 4 am
  Widget imageActionButton() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Visibility(
            visible: false,
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: Image(image: NetworkImage(widget.post.imageUrl))),
        actionsBar(),
      ],
    );
  }

  //* other options
  Widget otherOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //* comments button
          IconButton(
              onPressed: () {
                if (widget.post.allowComments) {
                  commentsBottomSheet(context, checkIfPostLiked(),
                      widget.post.likes, widget.post.postId, widget.post);
                }
              },
              icon: const Icon(IconPack.chat)),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: glowButtons(
                    title: "View",
                    buttonColor: Colors.grey.withOpacity(.7),
                    onClick: () {},
                    horizontalPadding: 0),
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                width: 120,
                child: glowButtons(
                    title: checkIfPostIsSaved(postId: widget.post.postId)
                        ? "UnSave"
                        : "Save",
                    buttonColor: checkIfPostIsSaved(postId: widget.post.postId)
                        ? Colors.grey.withOpacity(.3)
                        : Colors.red.withOpacity(.9),
                    onClick: () {
                      saveOrRemoveSave(postId: widget.post.postId);
                    },
                    horizontalPadding: 0),
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share))
        ],
      ),
    );
  }

  //* comments section
  Widget commentsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Divider(
            thickness: .5,
            color: Colors.grey.withOpacity(.2),
          ),
        ),

        //* like button
        likeRow(),
        //* comments
        commentRow(),
        SizedBox(
          height: 12,
        )
      ],
    );
  }

  //* text and like button
  Widget likeRow() {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "What do you think?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton(
                onPressed: () {
                  if (checkIfPostLiked()) {
                    setState(() {
                      _postsServices.disLikePost(
                          postId: widget.post.postId, context: context);
                      widget.post.likes -= 1;
                      currentUser!.likedPosts.remove(widget.post.postId);
                    });
                  } else {
                    setState(() {
                      _postsServices.likePost(
                          postId: widget.post.postId,
                          ownerId: widget.post.ownerId,
                          context: context);
                      widget.post.likes += 1;
                      currentUser!.likedPosts.add(widget.post.postId);
                    });
                  }
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.post.likes.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
      );
    });
  }

  //* comment row
  Widget commentRow() {
    return GestureDetector(
      onTap: () {
        commentsBottomSheet(context, checkIfPostLiked(), widget.post.likes,
            widget.post.postId, widget.post);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            profileWidget(
                imageUrl: currentUser!.pfpUrl,
                userName: currentUser!.userName,
                size: 45),
            const SizedBox(
              width: 12,
            ),
            Flexible(
              // width: MediaQuery.sizeOf(context).width / 1.5,
              child: costumeInputFiled(
                  verticalPadding: 6,
                  hintText: "Add a comment",
                  horizontalPadding: 0,
                  textController: _commentController,
                  isActive: false),
            )
          ],
        ),
      ),
    );
  }
} /* */
