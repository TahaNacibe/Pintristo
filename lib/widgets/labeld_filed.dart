import 'package:flutter/material.dart';
import 'package:pintresto/widgets/my_divider.dart';

//* actual widget
Widget labeledTextFiled({
  required String hintText,
  double verticalPadding = 6,
  double horizontalPadding = 15,
  required String label,
  required TextEditingController textController,
}) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        child: TextField(
          controller: textController,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          decoration: InputDecoration(
            label: Text(label),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(
                fontWeight: FontWeight.w300, color: Colors.grey, fontSize: 18),
          ),
        ),
      ),
      myDivider()
    ],
  );
}
