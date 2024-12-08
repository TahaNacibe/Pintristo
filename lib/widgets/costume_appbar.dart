import 'package:flutter/material.dart';

PreferredSizeWidget costumeAppBar({required String title, required BuildContext context}){
  return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
}