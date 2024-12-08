import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/screens/Chats/chats/image_view.dart';

Widget imageDisplay({
  required List<String?> urls,
  required BuildContext context,
}) {

  // Handle cases based on the number of URLs
  if (urls.isEmpty || urls.every((url) => url == null)) {
    return const SizedBox(); // Return an empty box if there are no URLs
  }

  // Ensure all URLs are non-null for safety
  List<String> nonNullUrls = urls.whereType<String>().toList();

  // Display single image
  if (nonNullUrls.length == 1) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 300,
        height: 200,
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageView(url: nonNullUrls[0])));
            },
            child: costumeImage(url: nonNullUrls[0])),
      ),
    );
  }

  // Display four or more images in a grid
  else {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling
        itemCount: nonNullUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.2,
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ImageView(url: nonNullUrls[index])));
                },
                child: CachedNetworkImage(
                  imageUrl:  nonNullUrls[index],
                  errorWidget: (context, url, error) => Container(color: Colors.grey.withOpacity(.3),),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget to create an image container
// Widget to create an image container
Widget costumeImage({required String url}) {
  return Image(
    image: NetworkImage(url),
    fit: BoxFit.cover,
  );
}
