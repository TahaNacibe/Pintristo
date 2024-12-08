import 'package:flutter/material.dart';

//* for reducing the code size
final InputBorder borderSkin = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: BorderSide(color: Colors.grey.withOpacity(.2), width: .5),
);

//* actual widget
Widget searchFiled(
    {required String hintText,
    required bool isEditing,
    required VoidCallback onWrite,
    required TextEditingController textController,
    Widget trailing = const SizedBox.shrink()}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
    child: TextField(
      controller: textController,
      onChanged: (_) => onWrite(),
      autofocus: false,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          fillColor: Colors.grey.withOpacity(.1),
          filled: true,
          border: borderSkin,
          enabledBorder: borderSkin,
          focusedBorder: borderSkin,
          hintText: hintText,
          hintStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 18),
          prefixIcon: isEditing ? null : const Icon(Icons.search),
          suffixIcon: isEditing ? trailing : null),
    ),
  );
}
