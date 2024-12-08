import 'package:flutter/material.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/screens/Settings/widgets/settings_item.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class NotificationsState extends StatefulWidget {
  const NotificationsState({super.key});

  @override
  State<NotificationsState> createState() => _NotificationsStateState();
}

class _NotificationsStateState extends State<NotificationsState> {
  bool allowNotifications = true;
  bool isLoading = true;
  //* instances
  NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());
  //* functions
  void updateNotificationState(bool value) {
    setState(() {
      allowNotifications = value;
      _notificationsServices.saveAllowNotifications(value);
    });
  }

  //*
  @override
  void initState() {
    _notificationsServices.getAllowNotifications().then((state) {
      setState(() {
        allowNotifications = state;
        isLoading = false;
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
        "Notifications",
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
            "Turn notifications off, you will not receive any notifications in or outside the app as long as it's stay off",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey.withOpacity(.5)),
          ),
        ),
        settingsItem(
            title: "Allow Notifications",
            details: "changes may take some time to tack effect",
            haveTiling: true,
            onClick: () {
              updateNotificationState(!allowNotifications);
            },
            trailing: Switch(
                value: allowNotifications,
                onChanged: (value) {
                  updateNotificationState(value);
                }))
      ],
    );
  }
}
