  import 'package:flutter/material.dart';
//* Costume button

Widget optionText(
      {required String text,
      required IconData icon,
      required VoidCallback onClick}) {
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
