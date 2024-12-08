import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/widgets/costume_appbar.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({super.key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
  bool showPassword = false;
  //* instances
  final AuthServices _authServices = AuthServices();
  void toggleVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Map<String, dynamic> isButtonActive() {
    if (_passwordTextController.text.isEmpty &&
        _confirmPasswordTextController.text.isEmpty) {
      return {"message": null, "case": false};
    } else if (_passwordTextController.text.length < 8) {
      return {
        "message": "password too short, at least 8 characters long",
        "case": false
      };
    } else if (_passwordTextController.text !=
        _confirmPasswordTextController.text) {
      return {"message": "Password don't match", "case": false};
    } else {
      return {"message": null, "case": true};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: costumeAppBar(title: "Password Manager", context: context),
      body: passwordManager(),
    );
  }

  //* body
  Widget passwordManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Enter New password",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
        ),
        costumeInputFiled(
            obscureText: !showPassword,
            onChange: (_) => setState(() {}),
            trailing: IconButton(
                onPressed: () {
                  toggleVisibility();
                },
                icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility)),
            horizontalPadding: 8,
            hintText: "Password",
            textController: _passwordTextController),
        costumeInputFiled(
            obscureText: !showPassword,
            onChange: (_) => setState(() {}),
            trailing: IconButton(
                onPressed: () {
                  toggleVisibility();
                },
                icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility)),
            horizontalPadding: 8,
            hintText: "Confirm Password",
            textController: _confirmPasswordTextController),
        const SizedBox(
          height: 16,
        ),
        glowButtons(
            title: "Update Password",
            isEnabled: isButtonActive()["case"],
            buttonColor: Colors.red.withOpacity(.7),
            onClick: () {
              _authServices
                  .updatePassword(password: _passwordTextController.text)
                  .then((result) {
                if (result) {
                  Navigator.pop(context);
                }
              });
            }),
        if (isButtonActive()["message"] != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isButtonActive()["message"],
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.red.withOpacity(.7)),
            ),
          ),
      ],
    );
  }
}
