import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/services/download_services.dart';
import 'package:pintresto/services/posts_services.dart';

class PinsOptions extends StatefulWidget {
  final PostModel post;
  final VoidCallback onDelete;
  final PostsServices postService;
  final String currentUserId;
  const PinsOptions(
      {required this.post,
      required this.currentUserId,
      required this.postService,
      required this.onDelete,
      super.key});

  @override
  State<PinsOptions> createState() => _PinsOptionsState();
}

class _PinsOptionsState extends State<PinsOptions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min to take only necessary space
        children: [
          optionText(
              text: "Download",
              icon: Icons.download,
              onClick: () {
                showLoadingDialog(context);
                ImageDownloader
                    .downloadImage(widget.post.imageUrl, context)
                    .then((_) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              }),
          optionText(
              text: "Block User",
              icon: Icons.person_2_rounded,
              onClick: () {
                Navigator.pop(context);
              }),
          if (widget.post.ownerId == widget.currentUserId)
            optionText(
                text: "Delete Post",
                icon: IconPack.trash,
                onClick: () {
                  showLoadingDialog(context);
                  widget.postService
                      .deleteUserPost(
                          postId: widget.post.postId, context: context)
                      .then((result) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onDelete();
                  });
                }),
          optionText(
              text: "Report User",
              icon: Icons.report,
              onClick: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  //* Costume button
  Widget optionText(
      {required String text,
      required IconData icon,
      required VoidCallback onClick}) {
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void showOptionsForPins(BuildContext context, PostModel post,
    String currentUserId, PostsServices postService, void Function() onDelete) {
  showModalBottomSheet(
    isScrollControlled: true, // Allow the bottom sheet to be scrollable
    context: context,
    builder: (context) {
      return PinsOptions(
        postService: postService,
        post: post,
        currentUserId: currentUserId,
        onDelete: onDelete,
      );
    },
  );
}
