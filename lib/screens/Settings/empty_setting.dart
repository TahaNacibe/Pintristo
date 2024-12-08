import 'package:flutter/material.dart';
import 'package:pintresto/widgets/error_future.dart';

class SettingPlaceHolder extends StatefulWidget {
  const SettingPlaceHolder({super.key});

  @override
  State<SettingPlaceHolder> createState() => _SettingPlaceHolderState();
}

class _SettingPlaceHolderState extends State<SettingPlaceHolder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          errorWidget(text: "Don't think i will be doing those for now"),
        ],
      ),
    );
  }
}
