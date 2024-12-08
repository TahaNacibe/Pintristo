import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/Settings/pages/board_details.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class BoardItem extends StatefulWidget {
  final BoardModel board;
  final void Function(List<String> selectedIds) onDeleteEffect;
  final void Function() onBoardDelete;
  const BoardItem(
      {required this.board,
      required this.onDeleteEffect,
      required this.onBoardDelete,
      super.key});

  @override
  State<BoardItem> createState() => _BoardItemState();
}

class _BoardItemState extends State<BoardItem> {
  List<PostModel> boarderPosts = [];
  bool isLoading = true;
  //* instances
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());

  //* functions
  Future<void> updatePostsList() async {
    List<PostModel> fetchedPosts = [];
    for (String id in widget.board.postsIds) {
      PostModel? post =
          await _postsServices.getPostById(postId: id, context: context);
      if (post != null) {
        fetchedPosts.add(post);
      }
    }
    setState(() {
      boarderPosts = fetchedPosts;
      isLoading = false;
    });
  }

  String? getImageIfExist({required List<PostModel> urls, required int index}) {
    if (urls.length > index) {
      return urls[index].imageUrl;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    updatePostsList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loadingPlaceHolder() : displayWidget();
  }

  Widget loadingPlaceHolder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: Colors.grey.withOpacity(.5), width: .5)),
          child: loadingWidget()),
    );
  }

  Widget displayWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BoardDetails(
                      board: widget.board,
                      boardPosts: boarderPosts,
                      delete: (selectedIds) {
                        widget.onDeleteEffect(selectedIds);
                      },
                      onBoardDelete: () {
                        widget.onBoardDelete();
                      },
                    )));
      },
      child: Stack(
        children: [
          boardItem(board: widget.board),
          if (widget.board.postsIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                        stops: [0.3, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(.5)
                        ])),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.board.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  "${widget.board.postsIds.length} Pins",
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

  Widget boardItem({required BoardModel board}) {
    List<PostModel> urls = boarderPosts;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: boardChild(url: getImageIfExist(urls: urls, index: 0)),
              ),
              //* Second column with two images
              VerticalDivider(
                width: 1.5,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: boardChild(
                          url: getImageIfExist(urls: urls, index: 1)),
                    ),
                    Divider(
                      height: 1.5,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    Expanded(
                      child: boardChild(
                          url: getImageIfExist(urls: urls, index: 2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget placeHolder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.3),
      ),
    );
  }

  Widget boardChild({required String? url}) {
    return url == null
        ? placeHolder()
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
  }
}
