//* contact item
  import 'package:flutter/material.dart';
import 'package:pintresto/widgets/profile_image.dart';

Widget contactItem(
      {required String? pfpUrl,
      required String name,
      required String? lastMessage}) {
    return ListTile(
      leading: profileWidget(imageUrl: pfpUrl, userName: name, size: 50),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      subtitle: Text(
        lastMessage ?? "Say hello",
        style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 25,
      ),
    );
  }
