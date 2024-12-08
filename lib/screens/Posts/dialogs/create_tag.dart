import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

void showCreateTagBottomSheet(
    BuildContext context, String tagName, VoidCallback onClick) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create $tagName ?",
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                "anyone will be able to use that tag on their posts",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: glowButtons(
                    title: "Create", buttonColor: Colors.red, onClick: onClick),
              )
            ],
          ),
        );
      });
}
