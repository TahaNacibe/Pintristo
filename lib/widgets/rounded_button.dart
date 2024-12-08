import 'package:flutter/material.dart';

Widget roundedButton({required IconData icon, required double padding}) {
  return Container(
    alignment: AlignmentDirectional.center,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.grey.withOpacity(.5)),
    child: Center(child: Icon(icon)),
  );
}
