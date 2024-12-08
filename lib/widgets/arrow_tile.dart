import 'package:flutter/material.dart';
import 'package:pintresto/widgets/my_divider.dart';

Widget arrowTile(
    {required String title,
    String actionHint = "",
    bool showDivider = true,
    required VoidCallback onClick}) {
  return InkWell(
    onTap: onClick,
    splashColor: Colors.transparent, // Disable ripple effect
    highlightColor:
        Colors.transparent, // Disable highlight effect on long press
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      actionHint,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios)
                ],
              )
            ],
          ),
        ),
        if (showDivider) myDivider()
      ],
    ),
  );
}
