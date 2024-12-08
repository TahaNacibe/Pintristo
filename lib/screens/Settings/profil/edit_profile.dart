import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/providers/user_provider.dart';
import 'package:pintresto/services/image_picker.dart';
import 'package:pintresto/services/image_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  String userName;
  String pfpUrl;
  String? coverUrl;
  VoidCallback onChangesTakeEffect;
  EditProfile(
      {required this.coverUrl,
      required this.pfpUrl,
      required this.userName,
      required this.onChangesTakeEffect,
      super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isEditing = false;
  bool isUpdatingCover = false;
  bool isUpdatingPfp = false;
  String? newCoverLink;
  String? newPfpLink;
  String? coverPath;
  String? pfpPath;
  //* instances
  final UserServices _userServices = UserServices();
  final FireImageServices _fireImageServices = FireImageServices();
  final ImageServices _imageServices = ImageServices();
  //* controllers
  TextEditingController userNameController = TextEditingController();

  void changeEditState() {
    setState(() {
      if (isEditing && userNameController.text.isEmpty) {
        informationBar(context, "Can't have an empty userName");
      } else {
        isEditing = !isEditing;
      }
    });
  }

  Future<void> updateCover() async {
    coverPath = await _imageServices.pickImage();
    setState(() {
      isUpdatingCover = false;
    });
  }

  Future<void> updatePfp() async {
    pfpPath = await _imageServices.pickImage();
    setState(() {
      isUpdatingPfp = false;
    });
  }

  Future<void> saveChanges() async {
    if (coverPath != null) {
      newCoverLink = await _fireImageServices.uploadUserImages(
          context: context,
          imagePath: coverPath!,
          oldImagePath: widget.coverUrl);
    }
    if (pfpPath != null) {
      newPfpLink = await _fireImageServices.uploadUserImages(
          context: context, imagePath: pfpPath!, oldImagePath: widget.pfpUrl);
    }
    Map<String, dynamic> update = {
      "pfpUrl": newPfpLink,
      "userCover": newCoverLink,
      "userName": widget.userName != userNameController.text
          ? userNameController.text
          : null
    };

    _userServices.updateUserData(update: update, context: context);
    widget.onChangesTakeEffect();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
     String newUsername = userNameController.text;
    // Update user data
  await userProvider.updateUserData(
    newPfpLink ?? widget.pfpUrl, // Use the existing one if new is null
    userProvider.username !=  newUsername? newUsername : userProvider.username // Only update if different
  );
    Navigator.pop(context);
  }

  @override
  void initState() {
    setState(() {
      userNameController.text = widget.userName;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarEditPage(),
      body: editPageBody(),
    );
  }

  //* app bar
  PreferredSizeWidget appBarEditPage() {
    return AppBar(
      centerTitle: true,
      title: const Text("Edit Profile"),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded)),
    );
  }

  //* edit body
  Widget editPageBody() {
    return Column(
      children: [
        //* images
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isUpdatingCover = true;
                  });
                  updateCover();
                },
                child: isUpdatingCover
                    ? updatedLoadingWidgetCover()
                    : Image(
                        image: coverPath != null
                            ? FileImage(File(coverPath!))
                            : NetworkImage(widget.coverUrl ?? ""),
                        fit: BoxFit.cover,
                        width: MediaQuery.sizeOf(context).width,
                        height: 220,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.withOpacity(.3),
                        ),
                      ),
              ),
              Positioned(
                top: 150,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isUpdatingPfp = true;
                      });
                      updatePfp();
                    },
                    child: isUpdatingPfp
                        ? updatedLoadingWidget()
                        : profileWidget(
                            imageUrl: pfpPath ?? widget.pfpUrl,
                            userName: widget.userName,
                            isOffline: pfpPath != null,
                            size: 120),
                  ),
                ),
              )
            ],
          ),
        ),
        //* details
        Expanded(
          child: Column(
            children: [
              editedTextFiled(
                  controller: userNameController,
                  isEditing: isEditing,
                  maxLength: 15,
                  onPress: changeEditState,
                  hint: "UserName"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Change display name and Profile image, cover image, useName must stay under 15 letter in length, any use of offensive language will cause in canceling the changes",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey.withOpacity(.7)),
                ),
              )
            ],
          ),
        ),

        //* save button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: glowButtons(
              title: "Save changes",
              buttonColor: Colors.red.withOpacity(.7),
              onClick: () {
                showLoadingDialog(context);
                // update the user data
                saveChanges().then((_) {
                  Navigator.pop(context);
                });
              }),
        )
      ],
    );
  }

  //* edited text filed
  Widget editedTextFiled(
      {required TextEditingController controller,
      required bool isEditing,
      required VoidCallback onPress,
      int? maxLength,
      required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: TextField(
        controller: controller,
        readOnly: !isEditing,
        maxLength: maxLength,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: onPress,
                icon: Icon(isEditing ? Icons.done : Icons.edit)),
            label: Text(
              hint,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.only(left: 8),
            filled: true,
            fillColor: Colors.grey.withOpacity(.3),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.transparent))),
      ),
    );
  }

  //* loading widget
  Widget updatedLoadingWidget() {
    return ClipOval(
      child: Container(
        width: 120,
        height: 120,
        color: Colors.grey.withOpacity(.3),
        child: Center(child: loadingWidget()),
      ),
    );
  }

  Widget updatedLoadingWidgetCover() {
    return Container(
      color: Colors.grey.withOpacity(.3),
      child: Center(child: loadingWidget()),
    );
  }
}
