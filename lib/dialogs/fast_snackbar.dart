import 'package:flutter/material.dart';

void showFastSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Short duration
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
