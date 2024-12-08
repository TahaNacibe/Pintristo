import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/Settings/widgets/image_place_holder.dart';

class BoardPostItem extends StatefulWidget {
  final PostModel post;
  final bool isSelected;
  final bool isLiked;
  final VoidCallback onLike;
  const BoardPostItem(
      {required this.post,
      required this.isLiked,
      required this.isSelected,
      required this.onLike,
      super.key});

  @override
  State<BoardPostItem> createState() => _BoardPostItemState();
}

class _BoardPostItemState extends State<BoardPostItem> {
  bool isPostFavorite = false;
  @override
  void initState() {
    setState(() {
      isPostFavorite = widget.isLiked;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        pinItem(post: widget.post),
        if (widget.isSelected) Positioned.fill(child: selectOverLay())
      ],
    );
  }

  Widget pinItem({required PostModel post}) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align content to the start
      children: [
        pinItemWithContainer(
            post: widget.post, deleteAction: (_) {}, haveOnTap: true),
        ownerCard(
          url: post.ownerPfp,
          title: post.ownerName,
        ),
      ],
    );
  }

  Widget ownerCard({
    required String url,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align items at the start
        children: [
          SizedBox(
            height: 30, // Increased height for better visibility
            width: 30, // Increased width for better visibility
            child: ClipOval(
              child: ClipRect(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1, // Limit title to one line
                    overflow: TextOverflow
                        .ellipsis, // Add ellipsis if title is too long
                  ),
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: widget.onLike,
              icon: Icon(widget.isLiked
                  ? Icons.star_rate_rounded
                  : Icons.star_border_rounded))
        ],
      ),
    );
  }

  //* select overLay
  Widget selectOverLay() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(.6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.withOpacity(.3)),
              child: const Icon(
                Icons.done,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
