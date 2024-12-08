import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/glow_buttons.dart';

void showFullScreenBottomSheet(BuildContext context, String email) {
  showModalBottomSheet(
    context: context,
    isDismissible: false, // Prevent dismissing by tapping outside
    isScrollControlled: true,
    enableDrag: false, // Prevent dragging to dismiss
    builder: (BuildContext context) {
      return FullscreenBottomSheet(
        email: email,
      );
    },
  );
}

class FullscreenBottomSheet extends StatefulWidget {
  final String email;
  const FullscreenBottomSheet({required this.email, super.key});

  @override
  FullscreenBottomSheetState createState() => FullscreenBottomSheetState();
}

class FullscreenBottomSheetState extends State<FullscreenBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isHidden = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SizedBox(height: 40), // For spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _currentPage > 0 ? Icons.arrow_back : Icons.close,
                      size: 28,
                    ),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            });
                          }
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Password field page
                    _buildInputPage(
                      context: context,
                      title: 'Create Password',
                      textController: _passwordController,
                      obscureText: isHidden,
                      tiling: IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                          },
                          icon: Icon(isHidden
                              ? Icons.visibility_off
                              : Icons.visibility)),
                      buttonTitle: 'Next',
                      onButtonPressed: () {
                        if (_passwordController.text.isEmpty) {
                          _showErrorMessage('Password cannot be empty');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      bottomInset: bottomInset,
                    ),
                    // Repeat password field page
                    _buildInputPage(
                      context: context,
                      title: 'Repeat Password',
                      textController: _repeatPasswordController,
                      obscureText: isHidden,
                      tiling: IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                          },
                          icon: Icon(isHidden
                              ? Icons.visibility_off
                              : Icons.visibility)),
                      buttonTitle: 'Next',
                      onButtonPressed: () {
                        if (_repeatPasswordController.text.isEmpty) {
                          _showErrorMessage('Please repeat your password');
                        } else if (_repeatPasswordController.text !=
                            _passwordController.text) {
                          _showErrorMessage(
                              'Passwords do not match'); // Ensure passwords match
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      bottomInset: bottomInset,
                    ),
                    // Username field page
                    _buildInputPage(
                      context: context,
                      title: 'Create Username',
                      textController: _usernameController,
                      obscureText: false,
                      tiling: const SizedBox.shrink(),
                      buttonTitle: 'Done',
                      onButtonPressed: () {
                        if (_usernameController.text.isEmpty) {
                          _showErrorMessage('Username cannot be empty');
                        } else if (_passwordController.text.isEmpty ||
                            _repeatPasswordController.text.isEmpty) {
                          _showErrorMessage(
                              'Password fields cannot be empty'); // Final check for all fields
                        } else if (_passwordController.text !=
                            _repeatPasswordController.text) {
                          _showErrorMessage("Password doesn't match");
                        } else {
                          AuthServices().signUpWithEmail(
                              widget.email,
                              _passwordController.text,
                              _usernameController.text,
                              context);
                              // ToDo transport him to verification page
                          Navigator.pop(context); // Close the sheet
                        }
                      },
                      bottomInset: bottomInset,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to handle each input page
  Widget _buildInputPage({
    required BuildContext context,
    required String title,
    required Widget tiling,
    required TextEditingController textController,
    required bool obscureText,
    required String buttonTitle,
    required VoidCallback onButtonPressed,
    required double bottomInset,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: bottomInset), // Padding to move above the keyboard
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8), // Space between title and field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: costumeInputFiled(
                    hintText: title,
                    obscureText: obscureText,
                    horizontalPadding: 8,
                    trailing: tiling,
                    textController: textController,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: glowButtons(
              title: buttonTitle,
              buttonColor: Colors.blue, // Unified button color
              onClick: onButtonPressed,
            ),
          ),
          const SizedBox(height: 20), // Small space at the bottom
        ],
      ),
    );
  }

  // Function to show an error message using a snackbar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
