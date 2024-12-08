import 'package:flutter/material.dart';

Widget tagWidget({required String title, required bool isSelected,required VoidCallback onClick}) {
  //* decide display color
  Color itemColor =
      isSelected ? Colors.grey.withOpacity(.7) : Colors.grey.withOpacity(.3);
  return GestureDetector(
    onTap: onClick,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: itemColor),
      child: Center(
          child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      )),
    ),
  );
}
