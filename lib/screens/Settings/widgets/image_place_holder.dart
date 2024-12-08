import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/ForYouPage/pin_screen.dart';
import 'package:pintresto/widgets/loading_widget.dart';

Widget pinItemWithContainer(
    {required PostModel post,
    required void Function(String id) deleteAction,
    bool haveOnTap = true}) {
  return FutureBuilder<Size>(
    future: _getImageSize(post.imageUrl),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        // When the image size is available, calculate the aspect ratio
        double aspectRatio = snapshot.data!.width / snapshot.data!.height;

        return InkWell(
          onTap: haveOnTap
              ? null
              : () {
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
