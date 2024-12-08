import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/providers/user_provider.dart';
import 'package:pintresto/screens/Settings/dialogs/account_managment.dart';
import 'package:pintresto/screens/Settings/empty_setting.dart';
import 'package:pintresto/screens/Settings/notification_contrl.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/screens/Settings/profile_visibility.dart';
import 'package:pintresto/screens/Settings/widgets/settings_item.dart';
import 'package:pintresto/screens/authScreens/sign_in_screen.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  String? pfpUrl;
  String userName;
  AccountSettings({required this.pfpUrl, required this.userName, super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  //* vars

  //* functions
  void moveToPlaceHolder() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingPlaceHolder()));
  }

  final AuthServices _authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: costumeAppBar(),
      body: SingleChildScrollView(child: bodyForSettingsPage()),
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
        "Your account",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  //* body widget
  Widget bodyForSettingsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          // Check if an update has happened
          if (userProvider.updateHappen) {
              widget.pfpUrl = userProvider.profilePictureUrl;
              widget.userName = userProvider.username;
            // userProvider.resetUpdateHappen();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* profile widget
              settingsItem(
                  title: widget.userName,
                  details: "View profile",
                  onClick: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage(
                                  isCurrentUser: true,
                                )));
                  },
                  leading: profileWidget(
                      imageUrl: widget.pfpUrl,
                      userName: widget.userName,
                      size: 45)),
              //* settings section
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  "Settings",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              //* settings options
              settingsItem(
                  title: "Account management",
                  details: null,
                  onClick: () {
                    showBottomSheetSettings(context);
                  }),
              settingsItem(
                  title: "Profile visibility",
                  details: null,
                  onClick: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileVisibility()));
                  }),
              settingsItem(
                  title: "Home feed tuner",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Claimed accounts",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Social permissions",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Notifications",
                  details: null,
                  onClick: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsState()));
                  }),
              settingsItem(
                  title: "Privacy and data",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Report and violations center",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              //* login section
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              //* items
              settingsItem(
                  title: "Add account",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Security",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Log out",
                  details: null,
                  onClick: () {
                    //*
                    showLoadingDialog(context);
                    _authServices.signOut(context).then((_) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LogInPage()));
                    });
                  }),
              //* Support section
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  "Support",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              settingsItem(
                  title: "Help center",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Terms of services",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "Privacy policy",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
              settingsItem(
                  title: "About",
                  details: null,
                  onClick: () {
                    moveToPlaceHolder();
                  }),
            ],
          );
        }),
      ),
    );
  }
}
