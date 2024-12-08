import 'package:flutter/material.dart';

Widget settingsItem({
  required String title,
  required String? details,
  required VoidCallback onClick,
  bool haveTiling = false,
  Widget trailing = const SizedBox.shrink(),
  Widget leading = const SizedBox.shrink(),
}) {
  return GestureDetector(
    onTap: onClick,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align at the top to allow multi-line
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Ensures multi-line alignment
                children: [
                  leading,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                        if (details != null)
                          Text(
                            details,
                            maxLines: null,
                            softWrap: true,
                            overflow: TextOverflow
                                .visible, // Ensure it overflows naturally
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            haveTiling
                ? trailing
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 23,
                  ),
          ],
        ),
      ),
    ),
  );
}
