import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

Future<int?> showGridBottomSheet(BuildContext context, int grid) async {
  int? result = await showModalBottomSheet<int>(
    context: context,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Ensure modal takes only necessary space
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Feed Layout Options",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          optionItem(
            name: "Wide",
            isActive: grid == 1,
            onPress: () {
              Navigator.pop(context, 1); // Return selected grid value
            },
          ),
          optionItem(
            name: "Standard",
            isActive: grid == 2,
            onPress: () {
              Navigator.pop(context, 2);
            },
          ),
          optionItem(
            name: "Compact",
            isActive: grid == 3,
            onPress: () {
              Navigator.pop(context, 3);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: glowButtons(
                    title: "Close",
                    buttonColor: Colors.red,
                    horizontalPadding: 2,
                    onClick: () {
                      Navigator.pop(context, grid); // Close without changes
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  return result ??
      grid; // Return selected grid or previous grid value if no selection
}

//* Option Item
Widget optionItem(
    {required String name,
    required bool isActive,
    required VoidCallback onPress}) {
  return InkWell(
    splashColor: Colors.transparent,
    onTap: onPress,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          if (isActive)
            const Icon(
              Icons.done,
              size: 35,
            ),
        ],
      ),
    ),
  );
}
