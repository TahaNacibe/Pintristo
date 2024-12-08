import 'package:flutter/material.dart';

Widget ideaHolderItem({required String tag, required String? imageUrl}) {
  return imageUrl != null
      ? ideaImageDisplay(tag: tag, imageUrl: imageUrl)
      : ideaDisplayNoImage(tag: tag);
}

Widget ideaImageDisplay({required String tag, required String imageUrl}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(imageUrl), fit: BoxFit.cover, opacity: .7),
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withOpacity(.5)),
    child: Center(
      child: Text(
        tag,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
    ),
  );
}

Widget ideaDisplayNoImage({required String tag}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withOpacity(.3)),
    child: Center(
      child: Text(
        tag,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
    ),
  );
}
