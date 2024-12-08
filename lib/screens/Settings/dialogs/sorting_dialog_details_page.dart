import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

Future<Map<String, dynamic>> showGridBottomSheetForDetailsPage(
    BuildContext context, int grid, bool favorite) async {
  return await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          bool isFavorite = favorite; // Local state for favorite filter
          int selectedGrid = grid; // Local state for grid layout

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Ensure modal takes only necessary space
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Filter by type",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  optionItem(
                    name: "All Pins",
                    isActive: !isFavorite,
                    onPress: () {
                      // Close and return immediately after selection
                      Navigator.pop(
                          context, {'grid': selectedGrid, 'favorite': false});
                    },
                  ),
                  optionItem(
                    name: "Favorites",
                    isActive: isFavorite,
                    onPress: () {
                      // Close and return immediately after selection
                      Navigator.pop(
                          context, {'grid': selectedGrid, 'favorite': true});
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Feed Layout Options",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  optionItem(
                    name: "Wide",
                    isActive: selectedGrid == 1,
                    onPress: () {
                      // Close and return immediately after selection
                      Navigator.pop(
                          context, {'grid': 1, 'favorite': isFavorite});
                    },
                  ),
                  optionItem(
                    name: "Standard",
                    isActive: selectedGrid == 2,
                    onPress: () {
                      // Close and return immediately after selection
                      Navigator.pop(
                          context, {'grid': 2, 'favorite': isFavorite});
                    },
                  ),
                  optionItem(
                    name: "Compact",
                    isActive: selectedGrid == 3,
                    onPress: () {
                      // Close and return immediately after selection
                      Navigator.pop(
                          context, {'grid': 3, 'favorite': isFavorite});
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
                              Navigator.pop(context,
                                  {'grid': grid, 'favorite': isFavorite});
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
        },
      ) ??
      {
        'grid': grid,
        'favorite': favorite
      }; // Default return in case of no selection
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
