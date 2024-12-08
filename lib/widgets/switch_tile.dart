import 'package:flutter/material.dart';

Widget switchTile(
    {required String title,
    required bool value,
    required void Function(bool state) onSwitch}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Builder(builder: (context) {
      //* vars for display
      Color fancyColor = Theme.of(context).iconTheme.color!;
      Color darkColor = Theme.of(context).cardColor;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          Switch(
            value: value,
            onChanged: onSwitch,
            //* active Ui
            activeColor: darkColor,
            activeTrackColor: fancyColor,
            //* inactive Ui
            inactiveTrackColor: darkColor,
            inactiveThumbColor: fancyColor,
            //*
            trackOutlineColor: WidgetStateProperty.all(Colors.white),
          )
        ],
      );
    }),
  );
}
