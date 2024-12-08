import 'package:flutter/material.dart';

Widget glowButtons(
    {required String title,
    required Color buttonColor,
    required void Function() onClick,
    bool isEnabled = true,
    double horizontalPadding = 40,
    Widget icon = const SizedBox.shrink()}) {
  return GestureDetector(
    onTap: onClick,
    child: Padding(
      padding:
          EdgeInsets.symmetric(vertical: 4.0, horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isEnabled ? buttonColor : Colors.grey.withOpacity(.7),
        ),
        child: Row(
          children: [
            icon,
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
