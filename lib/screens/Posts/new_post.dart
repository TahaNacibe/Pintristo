import 'package:flutter/material.dart';
import 'package:pintresto/screens/Posts/dialogs/create_bord_dialog.dart';
import 'package:pintresto/screens/Posts/post_screen.dart';
import 'package:pintresto/screens/Posts/widgets/button_cube.dart';
import 'package:pintresto/services/image_picker.dart';

void showPostBottomSheet(BuildContext context) {
  //* instances initialization
  ImageServices imageServices = ImageServices();

  //* function declaration
  void pinButton() {
    imageServices.pickImage().then((imagePath) {
      if (imagePath != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(
                      imagePath: imagePath,
                    )));
      } else {
        Navigator.pop(context);
      }
    });
  }

  //* Ui tree
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 200, // Adjust height as needed
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              // Updated to position the close button on the left and title in the center
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                ),
                const Text(
                  'Start Creating Now',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48), // Placeholder for alignment
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cubicButton(
                    title: "Pin",
                    icon: Icons.attachment,
                    onTap: () {
                      //* pick image then continue to the post details screen
                      pinButton();
                    }),
                cubicButton(title: "Collage", icon: Icons.cut, onTap: () {}),
                cubicButton(
                    title: "Board",
                    icon: Icons.border_all_rounded,
                    onTap: () {
                      showCreateBoardBottomSheet(context);
                    }),
              ],
            ),
            // Removed the previous IconButton as it's now in the title row
          ],
        ),
      );
    },
  );
}
