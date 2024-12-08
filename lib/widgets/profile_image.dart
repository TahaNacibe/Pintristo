import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/widgets/loading_widget.dart';

Widget profileWidget(
    {required String? imageUrl,
    required String userName,
    required double size,
    bool isOffline = false}) {
  return ClipOval(
    child: ClipRRect(
      child: imageUrl != null
          ? (isOffline
              ? offlineImageBuilder(imagePath: imageUrl, size: size)
              : imageBuilder(
                  imageUrl: imageUrl, userName: userName, size: size))
          : imageError(userName: userName, size: size),
    ),
  );
}

//* image widget
Widget imageBuilder(
    {required imageUrl, required String userName, required double size}) {
  return Image(
    width: size,
    height: size,
    errorBuilder: (context, error, stackTrace) {
      return imageError(userName: userName, size: size);
    },
    loadingBuilder: (context, child, loadingProgress) {
      return loadingPfp(loadingProgress, child);
    },
    image: CachedNetworkImageProvider(
      imageUrl,
    ),
    fit: BoxFit.cover,
  );
}

//* error widget
Widget imageError({required String userName, required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.red.withOpacity(.7)),
    child: Center(
      child: Text(
        userName[0].toUpperCase(),
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
    ),
  );
}

//* edit case
Widget offlineImageBuilder({required imagePath, required double size}) {
  return Image(
    width: size,
    height: size,
    image: FileImage(File(imagePath)),
    fit: BoxFit.cover,
  );
}

//* loading image
Widget loadingPfp(ImageChunkEvent? loadingProgress, Widget child) {
  if (loadingProgress == null) {
    // If the image is fully loaded, show it
    return child;
  } else {
    // While the image is loading, show a loading indicator
    return Center(child: loadingWidget());
  }
}
