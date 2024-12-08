import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/ForYouPage/dialogs/pin_item_options.dart';

Widget pinItem({required PostModel post}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start, // Align content to the start
    children: [
      Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              height: 150,
            ), // Loading indicator
            errorWidget: (context, url, error) =>
                const Icon(Icons.error), // Error widget
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            // width: 100, // Make image span the width of its container
          ),
        ),
      ),
      ownerCard(
          url: post.ownerPfp,
          title: post.title.isEmpty ? post.ownerName : post.title,
          userName: post.ownerName,
          desc: post.description),
    ],
  );
}

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
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align items at the start
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
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1, // Limit description to two lines
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if description is too long
                    ),
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                showOptionsForPinsItems(context, userName);
              },
              icon: const Icon(Icons.more_horiz_outlined))
        ],
      ),
    );
  });
}
