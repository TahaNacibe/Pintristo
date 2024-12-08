import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/fast_snackbar.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/screens/authScreens/sign_in_screen.dart';
import 'package:pintresto/screens/authScreens/widgets/action_button.dart';
import 'package:pintresto/screens/home_page.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

class LogInScreen extends StatefulWidget {
  final String? emailInput;
  const LogInScreen({required this.emailInput, super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  //* instances
  final AuthServices _authServices = AuthServices();

  //* controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //* functions declarations
  void updateEmailText() {
    if (widget.emailInput != null) {
      emailController.text = widget.emailInput!;
    }
  }

  //* initial action
  @override
  void initState() {
    // set the user email that was written in the prevues page
    updateEmailText();
    super.initState();
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarForLogInPage(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12),
        child: Column(
          children: [
            //* button section
            buttonsSection(onFacebookClick: () {
              showFastSnackbar(
                  context, "Sorry That's function is still under development");
            }, onGoogleClick: () {
              showLoadingDialog(context);

              _authServices.signInWithGoogle(context: context).then((user) {
                if (user != null) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                }
              });
            }),

            //* or
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                "Or",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
            ),

            //* input section
            inputSection(),

            //* main button
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: glowButtons(
                  buttonColor: Colors.red,
                  title: "Continue",
                  onClick: () async {
                    showLoadingDialog(context);
                    _authServices
                        .signInWithEmail(emailController.text,
                            passwordController.text, context)
                        .then((user) {
                      if (user != null) {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      }
                    });
                  }),
            ),

            //* forget password button
            TextButton(
                onPressed: () {
                  _authServices.resetPassword(emailController.text, context);
                  showFastSnackbar(context, "Reset Email was sent");
                },
                child: Text(
                  "Forget Password?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).iconTheme.color),
                ))
          ],
        ),
      ),
    );
  }

  //* appBar widget
  PreferredSizeWidget appBarForLogInPage() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
            onPressed: () {
              //* take the user back to the sign in page (man i should've named them something else)
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LogInPage()));
            },
            icon: const Icon(
              Icons.close,
              size: 30,
            )),
      ),
      centerTitle: true,
      title: const Text(
        "Log In",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              color: Colors.grey.withOpacity(.3),
            ),
          )),
    );
  }

  Widget inputSection() {
    return Column(
      children: [
        costumeInputFiled(
            hintText: "Email address", textController: emailController),
        costumeInputFiled(
            hintText: "Enter your Password",
            textController: passwordController,
            verticalPadding: 0,
            trailing: IconButton(
                onPressed: () {}, icon: const Icon(Icons.visibility)),
            obscureText: true),
      ],
    );
  }
}
