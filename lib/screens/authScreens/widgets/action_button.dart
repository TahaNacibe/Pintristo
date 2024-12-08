//* buttons section widget
import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

//* size vars
const double _buttonImageSize = 30;

//* UI tree
Widget buttonsSection(
    {required void Function() onFacebookClick,
    required void Function() onGoogleClick}) {
  return Column(
    children: [
      glowButtons(
          onClick: onFacebookClick,
          title: "Continue with Facebook",
          buttonColor: Colors.indigo,
          icon: buttonImage(path: "assets/images/social.png")),
      glowButtons(
          onClick: onGoogleClick,
          title: "Continue with Google",
          buttonColor: Colors.grey.withOpacity(.7),
          icon: buttonImage(path: "assets/images/google.png"))
    ],
  );
}

//* button image
Widget buttonImage({required String path}) {
  return Image(
    image: AssetImage(path),
    width: _buttonImageSize,
    height: _buttonImageSize,
  );
}
