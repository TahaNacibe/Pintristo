import 'package:flutter/material.dart';
import 'package:pintresto/widgets/loading_widget.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black.withOpacity(0.6), // Dark background with opacity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded edges
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: loadingWidget()
        ),
      );
    },
  );
}
