import 'package:flutter/material.dart';

Widget boardItemWidget({required String title, required String? firstImage, required bool isSelectedItem}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          imageWidgetForBoard(firstImage: firstImage, title: title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 22),
            ),
          )
        ],
      ),
      if(isSelectedItem)
      isSelected()
    ],
  );
}

//* is selected widget
Widget isSelected() {
  return Container(
    width: 30,
    height: 30,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
    child: const Icon(
      Icons.done,
      color: Colors.white,
    ),
  );
}

Widget imageWidgetForBoard(
    {required String? firstImage, required String title}) {
  if (firstImage != null && firstImage != "pass") {
    //* display image
    return imageWidget(firstImage: firstImage);
  } else {
    //* set place holder
    return imagePlaceHolder(title: title);
  }
}

//* create the image display widget
Widget imageWidget({required String firstImage}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image(
        image: NetworkImage(firstImage),
        fit: BoxFit.cover,
        width: 65,
        height: 65,
      ));
}

//* create a place holder widget
Widget imagePlaceHolder({required String title}) {
  return Container(
    width: 65,
    height: 65,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.withOpacity(.3)),
    child: Center(
      child: Text(
        title[0],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ),
  );
}
