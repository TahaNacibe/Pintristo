import 'package:flutter/material.dart';

class PostInformation extends StatefulWidget {
  final String title;
  final String desc;
  const PostInformation({required this.title, required this.desc, super.key});

  @override
  State<PostInformation> createState() => _PostInformationState();
}

class _PostInformationState extends State<PostInformation> {
  bool displayState = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty)
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          const SizedBox(height: 12),
          if (widget.desc.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  displayState = !displayState;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Wrapping this Text widget in Expanded so it takes available space
                  Expanded(
                    child: Text(
                      widget.desc,
                      maxLines: displayState ? null : 2,
                      overflow: displayState
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 8), // Space between text and "more/less"
                  Text(
                    displayState ? "less" : "more",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
