import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/pin_item_options.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';

Widget customTwoColumnBuilder({
  required List<PostModel> posts,
  void Function(String id)? onRefresh,
}) {
  // Split the list into two lists for the columns
  List<PostModel> leftColumnPosts = [];
  List<PostModel> rightColumnPosts = [];

  for (int i = 0; i < posts.length; i++) {
    if (i % 2 == 0) {
      leftColumnPosts.add(posts[i]);
    } else {
      rightColumnPosts.add(posts[i]);
    }
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First column (left)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(leftColumnPosts.length, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pinItemWithContainer(
                          post: leftColumnPosts[index],
                          deleteAction: (id) {
                            rightColumnPosts
                                .removeWhere((elem) => elem.postId == id);
                            if (onRefresh != null) {
                              onRefresh(id);
                            }
                          }),
                      ownerCard(
                        url: leftColumnPosts[index].ownerPfp,
                        title: leftColumnPosts[index].title.isEmpty
                            ? leftColumnPosts[index].ownerName
                            : leftColumnPosts[index].title,
                        userName: leftColumnPosts[index].ownerName,
                        desc: leftColumnPosts[index].description,
                      ),
                    ],
                  );
                }),
              ),
            ),
            // Second column (right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(rightColumnPosts.length, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pinItemWithContainer(
                          post: rightColumnPosts[index],
                          deleteAction: (id) {
                            rightColumnPosts
                                .removeWhere((elem) => elem.postId == id);
                            if (onRefresh != null) {
                              onRefresh(id);
                            }
                          }),
                      ownerCard(
                        url: rightColumnPosts[index].ownerPfp,
                        title: rightColumnPosts[index].title.isEmpty
                            ? rightColumnPosts[index].ownerName
                            : rightColumnPosts[index].title,
                        userName: rightColumnPosts[index].ownerName,
                        desc: rightColumnPosts[index].description,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Widget for each post with image as background in Container
Widget pinItemWithContainer(
    {required PostModel post, required void Function(String id) deleteAction}) {
  return FutureBuilder<Size>(
    future: _getImageSize(post.imageUrl),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        // When the image size is available, calculate the aspect ratio
        double aspectRatio = snapshot.data!.width / snapshot.data!.height;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PinScreen(
                  post: post,
                  deleteAction: (postId) {
                    deleteAction(postId);
                  },
                ),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              margin: const EdgeInsets.all(4.0), // Add margin between items
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      } else {
        // Placeholder while loading the image size
        return Container(
          alignment: Alignment.center,
          height: 200, // Fallback height while loading
          margin: const EdgeInsets.all(4.0), // Add margin between items
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.4), // Placeholder color
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: loadingWidget()),
        );
      }
    },
  );
}

// Function to fetch the image dimensions
Future<Size> _getImageSize(String imageUrl) async {
  final Image image = Image.network(imageUrl);
  final Completer<Size> completer = Completer<Size>();
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      var myImage = info.image;
      Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
      completer.complete(size); // Completes with the image size
    }),
  );
  return completer.future;
}

// Owner info widget
Widget ownerCard({
  required String url,
  required String title,
  required String desc,
  required String userName,
}) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileWidget(imageUrl: url, userName: userName, size: 35),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showOptionsForPinsItems(context, userName);
            },
            icon: const Icon(Icons.more_horiz_outlined),
          )
        ],
      ),
    );
  });
}
