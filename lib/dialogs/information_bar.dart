import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void informationBar(BuildContext context, String message) {
  showTopSnackBar(Overlay.of(context),
      displayDuration: Duration(milliseconds: 200),
      Builder(builder: (context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.9)),
        child: Text(
          message,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: "Quick",
              decoration: TextDecoration.none,
              color: Theme.of(context).iconTheme.color),
        ));
  }));
}
