import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/keys/prefernces_keys.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';
import 'package:pintresto/screens/Posts/post_screen.dart';
import 'package:pintresto/screens/Settings/dialogs/boards_options.dart';
import 'package:pintresto/screens/Settings/dialogs/confirm_dialog.dart';
import 'package:pintresto/screens/Settings/dialogs/more_users_dialog.dart';
import 'package:pintresto/screens/Settings/dialogs/sorting_dialog_details_page.dart';
import 'package:pintresto/screens/Settings/widgets/board_post.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/image_picker.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/shared_prefernces.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/profile_image.dart';

class BoardDetails extends StatefulWidget {
  BoardModel board;
  final List<PostModel> boardPosts;
  final void Function(List<String> deletedPosts) delete;
  final void Function() onBoardDelete;
  BoardDetails(
      {required this.board,
      required this.boardPosts,
      required this.delete,
      required this.onBoardDelete,
      super.key});

  @override
  State<BoardDetails> createState() => _BoardDetailsState();
}

class _BoardDetailsState extends State<BoardDetails> {
  List<UserModel> contributorsData = [];
  List<PostModel> fullBoardPosts = [];
  List<String> selectedPosts = [];
  UserModel? user;
  String currentUserId = "";
  bool isFavorite = false;
  bool selectMood = false;
  bool showItemAfterDelay = false;
  int initialGrid = 3;
  //* instances
  final UserServices _userServices = UserServices();
  final BoardServices _boardServices = BoardServices();
  final ImageServices _imageServices = ImageServices();
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());
  final SharedPreferencesHelper _sharedPreferencesHelper =
      SharedPreferencesHelper();

  //* functions
  Future<void> getContributors() async {
    for (String userId in widget.board.contributors) {
      UserModel? contributor = await _userServices.getOtherUserDetails(
          userId: userId, context: context);
      if (contributor != null) {
        contributorsData.add(contributor);
      }
    }
    setState(() {});
  }

  bool isPostFavorite({required String postId}) {
    return user!.favorites.contains(postId);
  }

  void updateBoardGridPreferences(int result) {
    _sharedPreferencesHelper.saveInt(boardPinsKey, result);
  }

  void updateLikeState({required String postId, required bool state}) {
    user!.favorites.contains(postId)
        ? user!.favorites.remove(postId)
        : user!.favorites.add(postId);
    setState(() {});
  }

  void toggleShowItemAfterDelay() {
    Future.delayed(Duration(milliseconds: 410), () {
      setState(() {
        showItemAfterDelay = true;
      });
    });
  }

  void handleEntriesInSelectMode({required String postId}) {
    setState(() {
      selectedPosts.contains(postId)
          ? selectedPosts.remove(postId)
          : selectedPosts.add(postId);
      if (selectedPosts.isEmpty) {
        showItemAfterDelay = false;
        selectMood = false;
      }
    });
  }

  bool isPostSelected({required String postId}) {
    return selectedPosts.contains(postId);
  }

  void deleteItems() {
    setState(() {
      if (selectMood && selectedPosts.isNotEmpty) {
        fullBoardPosts.removeWhere((e) => selectedPosts.contains(e.postId));
        _boardServices.handleRemovingItemsFromBoards(
            context: context,
            boardId: widget.board.boardId,
            lastPostImageUrl: fullBoardPosts.lastOrNull != null
                ? fullBoardPosts.last.imageUrl
                : "",
            selectedIds: selectedPosts);
      }
      selectMood = false;
      widget.delete(selectedPosts);
      showItemAfterDelay = false;
    });
  }

  void getFullBoardsData() {
    _postsServices
        .updatePostsData(posts: widget.boardPosts, context: context)
        .then((value) {
      setState(() {
        fullBoardPosts = value;
      });
    });
  }

  @override
  void initState() {
    getContributors();
    getFullBoardsData();
    _userServices.getUserDetails(context).then((userDetails) {
      setState(() {
        user = userDetails;
      });
    });
    _sharedPreferencesHelper.getInt(boardPinsKey).then((result) {
      setState(() {
        initialGrid = result ?? 2;
      });
    });
    super.initState();
  }

  List<String> getBoardPostsIdsList() {
    return widget.boardPosts.map((elem) => elem.postId).toList();
  }

  //*
  bool isUserInBoard() {
    currentUserId = _userServices.getCurrentUserId();
    return widget.board.contributors.contains(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarForDetails(),
      body: boardDetailsBody(),
    );
  }

  //* app bar widget
  PreferredSizeWidget appBarForDetails() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            if (selectMood) {
              setState(() {
                selectMood = false;
                selectedPosts.clear();
                showItemAfterDelay = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(selectMood ? Icons.close : Icons.arrow_back_ios)),
      actions: [
        IconButton(
            onPressed: () {
              showOptionsForBoards(
                  context,
                  widget.board.name,
                  widget.board.isSecret,
                  widget.board.boardId,
                  //* board posts
                  getBoardPostsIdsList(), () {
                setState(() {
                  widget.board.isSecret = !widget.board.isSecret;
                });
              }, () {
                widget.onBoardDelete();
              }, (newItems) {
                setState(() {
                  widget.boardPosts.addAll(newItems);
                  getFullBoardsData();
                  widget.onBoardDelete();
                });
              });
            },
            icon: const Icon(Icons.more_horiz))
      ],
    );
  }

  //* body widget
  Widget boardDetailsBody() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: SingleChildScrollView(
            child: Column(
              children: [detailsBar(), itemsBuilder()],
            ),
          ),
        ),
      ],
    );
  }

  //* details bar
  Widget detailsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.board.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            "${widget.board.postsIds.length} Pins",
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                contributorsWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isUserInBoard())
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                // todo add pop up for that
                                if (!selectMood) {
                                  setState(() {
                                    selectMood = true;
                                    toggleShowItemAfterDelay();
                                  });
                                } else {
                                  showConfirmBottomSheetForBoardDelete(context,
                                          "Remove ${selectedPosts.length} Pins from ${widget.board.name}? ")
                                      .then((answer) {
                                    if (answer) {
                                      deleteItems();
                                    } else {
                                      setState(() {
                                        showItemAfterDelay = false;
                                        selectMood = false;
                                        selectedPosts.clear();
                                      });
                                    }
                                  });
                                }
                              },
                              icon: Row(
                                children: [
                                  Icon(IconPack.trash),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    width: selectMood ? 80 : 0,
                                    padding: selectMood
                                        ? EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4)
                                        : EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey.withOpacity(.3),
                                    ),
                                    child: selectMood && showItemAfterDelay
                                        ? Center(
                                            child: Text(
                                            "${selectedPosts.length} Posts",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16),
                                          ))
                                        : null,
                                  )
                                ],
                              )),
                          if (!selectMood)
                            IconButton(
                                onPressed: () {
                                  _imageServices.pickImage().then((imagePath) {
                                    if (imagePath != null) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PostScreen(
                                                    imagePath: imagePath,
                                                    initialBoard: widget.board,
                                                  )));
                                    }
                                  });
                                },
                                icon: Icon(Icons.add)),
                          if (!selectMood)
                            IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.star_rate_rounded)),
                        ],
                      ),
                    IconButton(
                        onPressed: () async {
                          Map<String, dynamic>? result =
                              await showGridBottomSheetForDetailsPage(
                                  context, initialGrid, isFavorite);
                          setState(() {
                            isFavorite = result["favorite"];
                            initialGrid = result["grid"];
                            updateBoardGridPreferences(initialGrid);
                          });
                        },
                        icon: const Icon(Icons.sort)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget contributorsWidget() {
    return GestureDetector(
      onTap: () async {
        if (isUserInBoard()) {
          //* add more users
          List<UserModel>? newAdded = await showMoreUsersSheet(
              context: context,
              alreadySelectedIds: widget.board.contributors,
              followingIds: user!.followingIds,
              boardId: widget.board.boardId);
          //*
          if (newAdded != null && newAdded.isNotEmpty) {
            showLoadingDialog(context);
            contributorsData.addAll(newAdded);
            List<String> addedIds =
                contributorsData.map((elem) => elem.userId).toList();
            _boardServices
                .addContractures(
                    ids: addedIds,
                    board: widget.board.boardId,
                    context: context)
                .then((value) {
              Navigator.pop(context);
            });
          }
          setState(() {});
        }
      },
      child: SizedBox(
        height: 50, // Define a fixed height for the contributor section
        width: contributorsData.length * 25.0 +
            45, // Dynamic width based on contributors
        child: Stack(
          children: [
            for (int i = 0; i < contributorsData.length; i++)
              Positioned(
                left: i * 25.0, // Adjust overlap distance
                child: profileWidget(
                    imageUrl: contributorsData[i].pfpUrl,
                    userName: contributorsData[i].userName,
                    size: 35),
              ),
            if (isUserInBoard())
              Positioned(
                left: contributorsData.length * 25.0, // Positioned at the end
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(.3),
                  ),
                  child: const Icon(Icons.person_add),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //* items builder
  Widget itemsBuilder() {
    return MasonryGridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fullBoardPosts.length,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: initialGrid),
        itemBuilder: (context, index) {
          bool isLikedPost =
              isPostFavorite(postId: fullBoardPosts[index].postId);
          return Visibility(
            visible: !isFavorite || (isLikedPost && isFavorite),
            child: GestureDetector(
              onTap: () {
                if (selectMood) {
                  handleEntriesInSelectMode(
                      postId: fullBoardPosts[index].postId);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PinScreen(
                                post: fullBoardPosts[index],
                                deleteAction: (postId) {
                                  setState(() {
                                    fullBoardPosts.removeWhere(
                                        (elem) => elem.postId == postId);
                                  });
                                },
                              )));
                }
              },
              onLongPress: () {
                setState(() {
                  if (selectMood) {
                    selectedPosts.clear();
                    showItemAfterDelay = false;
                  }
                  toggleShowItemAfterDelay();
                  selectMood = !selectMood;
                  handleEntriesInSelectMode(
                      postId: fullBoardPosts[index].postId);
                });
              },
              child: BoardPostItem(
                post: fullBoardPosts[index],
                isSelected:
                    isPostSelected(postId: fullBoardPosts[index].postId),
                isLiked: isLikedPost,
                onLike: () {
                  updateLikeState(
                      postId: fullBoardPosts[index].postId,
                      state:
                          isPostFavorite(postId: fullBoardPosts[index].postId));
                  _postsServices.setPinAsFavorite(
                      context: context,
                      postId: fullBoardPosts[index].postId,
                      isFavorite: !isLikedPost);
                },
              ),
            ),
          );
        });
  }
}
