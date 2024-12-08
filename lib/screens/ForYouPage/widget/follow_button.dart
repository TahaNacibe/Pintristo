import 'package:flutter/material.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

class FollowButton extends StatefulWidget {
  final bool isFollowed;
  final VoidCallback onClick;
  const FollowButton({required this.isFollowed, required this.onClick ,super.key});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: glowButtons(
          title: widget.isFollowed ? "UnFollow" : "Follow",
          buttonColor: Colors.red.withOpacity(widget.isFollowed ? .7 : .9),
          onClick: widget.onClick,
          horizontalPadding: 0),
    );
  }
}
