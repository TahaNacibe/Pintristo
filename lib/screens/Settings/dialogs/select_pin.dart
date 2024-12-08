import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/get_user_pins.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class SelectPinScreen extends StatefulWidget {
  final void Function(List<PostModel> posts) addPosts;
  final String boardId;
  final List<String> alreadyInPosts;
  const SelectPinScreen(
      {required this.addPosts,
      required this.boardId,
      required this.alreadyInPosts,
      super.key});

  @override
  State<SelectPinScreen> createState() => _SelectPinScreenState();
}

class _SelectPinScreenState extends State<SelectPinScreen> {
  //* vars
  bool isLoading = true;
  List<PostModel> postsList = [];
  List<int> selected = [];
  Map<String, dynamic>? userPosts;
  List<String> postsWatcher = [];
  //* instances
  AuthServices _authServices = AuthServices();
  BoardServices _boardServices = BoardServices();
  //* functions
  List<PostModel> getPostsList({required List<dynamic> items}) {
    List<PostModel> result = [];
    for (List<PostModel> list in items) {
      for (PostModel post in list) {
        if (!widget.alreadyInPosts.contains(post.postId)) {
          if (!postsWatcher.contains(post.postId)) {
            result.add(post);
            postsWatcher.add(post.postId);
          }
        }
      }
    }
    return result;
  }

  @override
  void initState() {
    GetUserPins()
        .getUserPins(
            userId: _authServices.getTheCurrentUserId(), context: context)
        .then((result) {
      setState(() {
        userPosts = result;
        isLoading = false;
        postsList = getPostsList(items: result.values.toList());
      });
    });

    super.initState();
  }

  List<PostModel> postsThatGotSelected() {
    List<PostModel> result = [];
    for (int index in selected) {
      result.add(postsList[index]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 100,
                    child: glowButtons(
                        isEnabled: selected.isNotEmpty,
                        horizontalPadding: 0,
                        title: "Add",
                        buttonColor: Colors.red,
                        onClick: () {
                          _boardServices
                              .addPinToBoard(
                                  context: context,
                                  boardId: widget.boardId,
                                  pinsIds: postsThatGotSelected()
                                      .map((elem) => elem.postId)
                                      .toList())
                              .then((_) {
                            widget.addPosts(postsThatGotSelected());
                            Navigator.pop(context);
                          });
                        })),
              )
            ],
          )),
      body: isLoading ? loadingWidget() : itemBuilder(),
    );
  }

  Widget itemBuilder() {
    return MasonryGridView.builder(
        shrinkWrap: true,
        itemCount: postsList.length,
        gridDelegate:
            SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          PostModel post = postsList[index];
          return postItem(post: post, index: index);
        });
  }

  Widget postItem({required PostModel post, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected.contains(index)) {
            selected.remove(index);
          } else {
            selected.add(index);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image(
                image: NetworkImage(post.imageUrl),
                loadingBuilder: (context, child, loadingProgress) {
                  return Center(
                    child: child,
                  );
                },
                fit: BoxFit.cover,
              ),
            ),
            if (selected.contains(index))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

void showBottomSheetToAddPins(
  BuildContext context,
  String boardId,
  List<String> alreadyInPosts,
  void Function(List<PostModel> posts) onAdd,
) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SelectPinScreen(
              addPosts: onAdd,
              alreadyInPosts: alreadyInPosts,
              boardId: boardId,
            ),
          ),
        );
      });
}
