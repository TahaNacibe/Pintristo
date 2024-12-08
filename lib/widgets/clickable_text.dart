import 'package:flutter/material.dart';

Widget clickableText({
  required String normalText,
  required String buttonText,
  required void Function() onClick,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        normalText,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      GestureDetector(
        onTap: onClick,
        child: Text(
          " $buttonText",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}
