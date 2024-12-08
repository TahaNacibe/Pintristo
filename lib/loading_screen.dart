import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/screens/authScreens/sign_in_screen.dart';
import 'package:pintresto/screens/home_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final AuthServices _authServices = AuthServices();
  @override
  void initState() {
    _authServices.isUserSignedIn().then((value) {
      Future.delayed(const Duration(seconds: 1), () {
        if (value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LogInPage()));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage("assets/images/pinterest.png"),
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
