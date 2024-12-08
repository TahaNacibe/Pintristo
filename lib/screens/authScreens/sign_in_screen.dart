import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/fast_snackbar.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/screens/authScreens/log_in_screen.dart';
import 'package:pintresto/screens/authScreens/widgets/action_button.dart';
import 'package:pintresto/screens/authScreens/widgets/infinit_scroll.dart';
import 'package:pintresto/screens/authScreens/widgets/sign_up.dart';
import 'package:pintresto/screens/home_page.dart';
import 'package:pintresto/widgets/clickable_text.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  //* instances
  final AuthServices _authServices = AuthServices();
  //* display vars
  final double _sizeForImagesWindow = 1.6;
  final double _appIconSize = 120;

  //* logic vars
  // Email validation pattern for @gmail.com
  final String gmailPattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
  String? responseFromServer;

  //* controllers
  TextEditingController emailController = TextEditingController();

  //* functions declaration
  String? getUserInputForEmail() {
    // Create a RegExp object with the pattern
    final RegExp gmailRegExp = RegExp(gmailPattern);
    if (gmailRegExp.hasMatch(emailController.text)) {
      return emailController.text;
    } else {
      return null;
    }
  }

  // check user before action
  Future<void> checkUserBeforeAction() async {
    responseFromServer =
        await _authServices.fetchUserData(emailController.text);
    // Switch case to handle response
    switch (responseFromServer.toString()) {
      case '1':
        showFastSnackbar(context, "this account signed in with google");
        break;
      case '2':
        showFastSnackbar(context, "signed in with email");
        Navigator.pop(context);
        //* take the user back to the sign in page (man i should've named them something else)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LogInScreen(
                      emailInput: getUserInputForEmail(),
                    )));
        break;
      case '3':
        showFastSnackbar(context, 'No user data found for this email.');
        //* sign up page
        showFullScreenBottomSheet(context, emailController.text);
        break;
      default:
        //* just error
        showFastSnackbar(
            context, 'Error fetching user data: $responseFromServer');
    }
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          //* the never ending scroll images
          const PinterestClone(),
          //* overLay of the screen
          pageOverLay(),
          //* details section
          detailsOfTheScreen(),
        ],
      ),
    );
  }

  Widget pageOverLay() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              // set color alignments
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
              // create the vanish effect
              stops: const [
            0,
            .42
          ],
              colors: [
            // colors to display
            Colors.transparent,
            Theme.of(context).scaffoldBackgroundColor
          ])),
    );
  }

  //* details section body
  Widget detailsOfTheScreen() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height / _sizeForImagesWindow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          //* app Icon
          appIcon(),
          //* title Bar
          titleTextWidget(),
          //* email input field
          costumeInputFiled(
              hintText: "Email address", textController: emailController),
          //* main button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: glowButtons(
                buttonColor: Colors.red,
                title: "Continue",
                onClick: () async {
                  checkUserBeforeAction();
                }),
          ),
          //* button section
          buttonsSection(onFacebookClick: () {
            showFastSnackbar(
                context, "Sorry That's function is still under development");
          }, onGoogleClick: () {
            showLoadingDialog(context);
            _authServices.signInWithGoogle(context: context).then((user) {
              if (user != null) {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              }
            });
          }),
          //* end page message
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: bottomPageMessage(),
          )
        ],
      ),
    );
  }

  //* app Icon
  Widget appIcon() {
    return Image(
      image: const AssetImage("assets/images/pinterest.png"),
      width: _appIconSize,
      height: _appIconSize,
    );
  }

  //* title text
  Widget titleTextWidget() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "Welcome To Pinteresto",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      ),
    );
  }

  //* bottom Page Message
  Widget bottomPageMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          clickableText(
              normalText: "By Continuing, you agree to our",
              buttonText: "Terms of Service",
              onClick: () {}),
          clickableText(
              normalText: "And acknowledge that you read our",
              buttonText: "Privacy Policy",
              onClick: () {}),
          clickableText(
              normalText: "",
              buttonText: "Notice at collection",
              onClick: () {}),
        ],
      ),
    );
  }
}
