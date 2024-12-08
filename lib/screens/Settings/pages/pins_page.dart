import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pintresto/keys/prefernces_keys.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';
import 'package:pintresto/screens/Posts/new_post.dart';
import 'package:pintresto/screens/Settings/dialogs/grid_dialog.dart';
import 'package:pintresto/services/get_user_pins.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/shared_prefernces.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class YourPinsPage extends StatefulWidget {
  final UserModel user;
  const YourPinsPage({required this.user, super.key});

  @override
  State<YourPinsPage> createState() => _YourPinsPageState();
}

class _YourPinsPageState extends State<YourPinsPage> {
  TextEditingController searchController = TextEditingController();
  int initialGrid = 3;
  bool showFavorite = false;
  bool showCreatedByMe = false;
  bool isSearching = false;
  bool isLoading = true;
  List<String> postsWatcher = [];
  List<PostModel> postsList = [];
  Map<String, dynamic>? userPosts;
  InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none);
  //* instances
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());
  final SharedPreferencesHelper _sharedPreferencesHelper =
      SharedPreferencesHelper();
  //* functions
  IconData getGridCountIcon() {
    return initialGrid == 3
        ? Icons.grid_3x3_rounded
        : initialGrid == 2
            ? Icons.grid_view_rounded
            : Icons.check_box_outline_blank_outlined;
  }

  void updateGridPreferences(int result) {
    _sharedPreferencesHelper.saveInt(pinsKey, result);
  }

  void deletePostById({required String id}) {
    postsList.removeWhere((elem) => elem.postId == id);
    setState(() {});
  }

  void changeGrid() {
    setState(() {
      initialGrid < 3 ? initialGrid += 1 : initialGrid = 1;
    });
  }

  List<PostModel> getPostsList({required List<dynamic> items}) {
    List<PostModel> result = [];
    for (List<PostModel> list in items) {
      for (PostModel post in list) {
        if (!postsWatcher.contains(post.postId)) {
          result.add(post);
          postsWatcher.add(post.postId);
        }
      }
    }
    return result;
  }

  bool? isItemInList({required PostModel post}) {
    if (showCreatedByMe && showFavorite) {
      return userPosts!["created"].contains(post) &&
          widget.user.favorites.contains(post.postId);
    } else if (showCreatedByMe) {
      return userPosts!["created"].contains(post);
    } else if (showFavorite) {
      return widget.user.favorites.contains(post.postId);
    } else {
      return null;
    }
  }

  bool isItemFavorite({required String postId}) {
    return widget.user.favorites.contains(postId);
  }

  void changeFavoriteState({required String postId, required bool isFavorite}) {
    setState(() {
      isFavorite = !isFavorite;
      _postsServices.setPinAsFavorite(
          context: context, postId: postId, isFavorite: isFavorite);
      if (isFavorite) {
        //* was added
        widget.user.favorites.add(postId);
      } else {
        //* was removed
        widget.user.favorites.remove(postId);
      }
    });
  }

  @override
  void initState() {
    GetUserPins()
        .getUserPins(userId: widget.user.userId, context: context)
        .then((result) {
      setState(() {
        userPosts = result;
        isLoading = false;
        postsList = getPostsList(items: result.values.toList());
      });
    });
    _sharedPreferencesHelper.getInt(pinsKey).then((result) {
      setState(() {
        initialGrid = result ?? 3;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(),
      body: !isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  itemBuilder(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${postsList.length} Pins Saved",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  )
                ],
              ),
            )
          : loadingWidget(),
    );
  }

  //* search bar
  PreferredSizeWidget searchAppBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          //* search functions
                          if (value.isNotEmpty) {
                            isSearching = true;
                          } else {
                            isSearching = false;
                          }
                          setState(() {});
                        },
                        onTap: () {},
                        onSubmitted: (value) {},
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 8),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  if (isSearching) {
                                    setState(() {
                                      isSearching = false;
                                      searchController.clear();
                                    });
                                  } else {
                                    showPostBottomSheet(context);
                                  }
                                },
                                icon: Icon(
                                    isSearching ? Icons.close : Icons.add)),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search)),
                            hintText: "Search your Pins",
                            filled: true,
                            fillColor: Colors.grey.withOpacity(.2),
                            border: border),
                      ),
                    ),
                  ],
                ),
                filterBar(),
              ],
            )));
  }

  //* filter buttons
  Widget filterButtons(
      {required Widget child,
      required bool? relatedBool,
      required VoidCallback onPress}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).iconTheme.color!,
                  width: (relatedBool != null && relatedBool) ? 1.5 : .8)),
          child: child,
        ),
      ),
    );
  }

  //* filter bar
  Widget filterBar() {
    return Row(
      children: [
        filterButtons(
            child: Icon(getGridCountIcon()),
            relatedBool: null,
            onPress: () async {
              //* change grid
              initialGrid = await showGridBottomSheet(context, initialGrid) ??
                  initialGrid;
              updateGridPreferences(initialGrid);
              setState(() {});
            }),
        filterButtons(
            child: const Row(
              children: [
                Icon(Icons.star_rate_rounded),
                Text(
                  "Favorites",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                )
              ],
            ),
            relatedBool: showFavorite,
            onPress: () {
              //* change the related bool state
              setState(() {
                showFavorite = !showFavorite;
              });
            }),
        filterButtons(
            child: const Text(
              "Created by you",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            relatedBool: showCreatedByMe,
            onPress: () {
              //* change the related bool state
              setState(() {
                showCreatedByMe = !showCreatedByMe;
              });
            })
      ],
    );
  }

  Widget itemBuilder() {
    return MasonryGridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: postsList.length,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: initialGrid),
        itemBuilder: (context, index) {
          PostModel post = postsList[index];
          return Visibility(
            visible: post.title.contains(searchController.text),
            child: Visibility(
                visible: isItemInList(post: post) ?? true,
                child: postItem(post: post)),
          );
        });
  }

  Widget postItem({required PostModel post}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PinScreen(
                      post: post,
                      deleteAction: (postId) {
                        deletePostById(id: postId);
                      },
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(
                    image: CachedNetworkImageProvider(post.imageUrl),
                    fit: BoxFit.cover)),
            if (initialGrid == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        changeFavoriteState(
                            postId: post.postId,
                            isFavorite: isItemFavorite(postId: post.postId));
                      },
                      icon: Icon(isItemFavorite(postId: post.postId)
                          ? Icons.star_rounded
                          : Icons.star_border))
                ],
              )
          ],
        ),
      ),
    );
  }
}
