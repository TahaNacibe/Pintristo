import 'package:flutter/material.dart';

class PinsOptions extends StatefulWidget {
  final String userName;
  const PinsOptions({required this.userName, super.key});

  @override
  State<PinsOptions> createState() => _PinsOptionsState();
}

class _PinsOptionsState extends State<PinsOptions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min to take only necessary space
        children: [
          optionText(
              text: "Hide Pin",
              icon: Icons.visibility_off,
              onClick: () {
                Navigator.pop(context);
              }),
          optionText(
              text: "See fewer Pins from ${widget.userName}",
              icon: Icons.person_2_rounded,
              onClick: () {
                Navigator.pop(context);
              }),
          optionText(
              text: "Report Pin",
              icon: Icons.report,
              onClick: () {
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

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
}

void showOptionsForPinsItems(BuildContext context, String userName) {
  showModalBottomSheet(
    isScrollControlled: true, // Allow the bottom sheet to be scrollable
    context: context,
    builder: (context) {
      return PinsOptions(
        userName: userName,
      );
    },
  );
}
