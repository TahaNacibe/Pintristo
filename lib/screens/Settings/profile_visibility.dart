import 'package:flutter/material.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Settings/widgets/settings_item.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class ProfileVisibility extends StatefulWidget {
  const ProfileVisibility({super.key});

  @override
  State<ProfileVisibility> createState() => _ProfileVisibilityState();
}

class _ProfileVisibilityState extends State<ProfileVisibility> {
  bool isVisible = true;
  bool isLoading = true;
  UserModel? userDetails;
  //* instances
  UserServices _userServices = UserServices();

  //* functions
  void updateVisibility(bool value) {
    _userServices.updateUserVisibility(state: value).then((_) {
      setState(() {
        isVisible = value;
      });
    });
  }

  //*
  @override
  void initState() {
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        if (user != null) {
          userDetails = user;
          isVisible = user.isVisible;
          isLoading = false;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: costumeAppBar(),
      body: isLoading ? loadingWidget() : bodyForSettingsPage(),
    );
  }

  PreferredSizeWidget costumeAppBar() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      title: const Text(
        "Profile Visibility",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  //* body widget
  Widget bodyForSettingsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Turn visibility off for profile so no longer search can find you, people who already have access to your profile by messages, following and or followers group boards or any other way will still be able to access your profile from these methods",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey.withOpacity(.5)),
          ),
        ),
        settingsItem(
            title: "Profile visibility",
            details:
                "Visibility may take some time to tack effect after changing",
            haveTiling: true,
            onClick: () {
              updateVisibility(!isVisible);
            },
            trailing: Switch(
                value: isVisible,
                onChanged: (value) {
                  updateVisibility(value);
                }))
      ],
    );
  }
}
