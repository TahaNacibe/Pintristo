import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart'; // Ensure you have the necessary imports

Future<bool> showConfirmBottomSheetForBoardDelete(BuildContext context, String message) async {
  // Define the result variable
  bool userChoice = false;

  // Show the bottom sheet and await the result
  userChoice = await showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(fontSize: 20), // Big title
              ),
              const SizedBox(height: 20), // Spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 100,
                      child: glowButtons(
                        title: "Cancel",
                        horizontalPadding: 0,
                        buttonColor: Colors.grey.withOpacity(.5),
                        onClick: () {
                          Navigator.of(context).pop(false); // Close bottom sheet and return false
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: glowButtons(
                      horizontalPadding: 0,
                      title: "Confirm",
                      buttonColor: Colors.red,
                      onClick: () {
                        Navigator.of(context).pop(true); // Close bottom sheet and return true
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ); // Default to false if bottom sheet is dismissed without choice

  return userChoice;
}
