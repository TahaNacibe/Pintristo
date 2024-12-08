import 'package:flutter/material.dart';
import 'package:pintresto/providers/theme_providers.dart';
import 'package:provider/provider.dart';
import 'package:pintresto/screens/Settings/password_change.dart';
import 'package:pintresto/screens/Settings/widgets/settings_item.dart';
import 'package:pintresto/widgets/costume_appbar.dart';

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      appBar: costumeAppBar(title: "Manage your account", context: context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your account",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
            settingsItem(
                title: "Personal information", details: null, onClick: () {}),
            settingsItem(title: "Email", details: null, onClick: () {}),
            settingsItem(
                title: "Password",
                details: "Change Password",
                onClick: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PasswordChange()));
                }),
            settingsItem(
                title: "Convert to a business account",
                details:
                    "Grow your business or brand with tools like ads and analytics, Your content, profile and followers will stay the same",
                onClick: () {}),
            
            // Theme switching section
            settingsItem(
                title: "App Theme",
                details: null,
                onClick: () {}, // No action needed for the text
                haveTiling: true,
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (value) {
                    themeProvider.toggleTheme(); // Toggle the theme
                  },
                )),
            settingsItem(
                title: "App Sound",
                details: "Turn on app sound from the Pintresto app ",
                onClick: () {},
                haveTiling: true,
                trailing: Switch(value: true, onChanged: (value) {})),
            const Text(
              "Your account",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
            settingsItem(
                title: "Deactivate account",
                details: "Deactivate to temporary hide your pins and profile",
                onClick: () {}),
            settingsItem(
                title: "Delete your data and account",
                details:
                    "Permanently delete your data and everything associated with your account",
                onClick: () {}),
          ],
        ),
      ),
    );
  }
}

void showBottomSheetSettings(BuildContext context) {
  showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.only(top: 35.0),
          child: AccountManagement(),
        );
      });
}
