import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

//* loading widget

Widget loadingWidget() {
  return Builder(builder: (context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: Theme.of(context).iconTheme.color!,
            size: 30,
          ),
        ),
      ],
    );
  });
}
