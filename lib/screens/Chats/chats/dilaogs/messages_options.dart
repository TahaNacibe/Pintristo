import 'package:flutter/material.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/widgets/option_button.dart';

void showMessagesOptions(
    BuildContext context, VoidCallback deleteAction, VoidCallback copyAction) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              optionText(
                  text: "Delete message",
                  icon: IconPack.trash,
                  onClick: deleteAction),
              optionText(
                  text: "Copy text", icon: Icons.copy, onClick: copyAction),
              optionText(
                  text: "Report Message", icon: Icons.report, onClick: () {})
            ],
          ),
        );
      });
}

