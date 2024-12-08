import 'package:flutter/material.dart';

//* for reducing the code size
final InputBorder borderSkin = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: BorderSide(color: Colors.grey.withOpacity(.7), width: 2.5),
);

//* actual widget
Widget costumeInputFiled(
    {required String hintText,
    bool obscureText = false,
    bool isActive = true,
    double verticalPadding = 14,
    double horizontalPadding = 40,
    required TextEditingController textController,
    void Function(String value)? onChange,
    Widget trailing = const SizedBox.shrink()}) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding),
    child: TextField(
      obscureText: obscureText,
      controller: textController,
      onChanged: (value) {
        if (onChange != null) {
          onChange(value);
        }
      },
      enabled: isActive,
      autofocus: false,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 8),
          border: borderSkin,
          enabledBorder: borderSkin,
          focusedBorder: borderSkin,
          hintText: hintText,
          hintStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 18),
          suffixIcon: trailing),
    ),
  );
}
