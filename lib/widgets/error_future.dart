import 'package:flutter/material.dart';

Widget errorWidget({required String text}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              "(0u0!)\n$text"),
        ),
      ),
    ],
  );
}
