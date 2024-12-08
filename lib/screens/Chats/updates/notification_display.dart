import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/models/notification_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/providers/time_manager.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/profile_image.dart';

class NotificationDisplay extends StatefulWidget {
  const NotificationDisplay({super.key});

  @override
  State<NotificationDisplay> createState() => _NotificationDisplayState();
}

class _NotificationDisplayState extends State<NotificationDisplay> {
  //* vars
  List<NotificationModel> notifications = [];
  List<int> selectedIndex = [];
  bool isPageLoading = true;
  bool isSelectionMood = false;

  //* instances
  final NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());

  //* functions
  void loadNotifyList() {
    _notificationsServices.loadUserNotifications(context).then((notifyList) {
      setState(() {
        notifications = notifyList;
        isPageLoading = false;
      });
    });
  }

  // get unread notifications
  int unreadCount() {
    return notifications.where((notify) => !notify.isSeen).length;
  }

  //
  void switchSelectMood(int initialIndex) {
    setState(() {
      if (isSelectionMood) {
        isSelectionMood = false;
        selectedIndex.clear();
      } else {
        selectedIndex.add(initialIndex);
        isSelectionMood = true;
      }
    });
  }

  List<NotificationModel> prepareListForDelete() {
    List<NotificationModel> result = [];
    for (int index in selectedIndex) {
      result.add(notifications[index]);
    }
    return result;
  }

  //* init
  @override
  void initState() {
    loadNotifyList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: notificationsScreenAppBar(),
      body: RefreshIndicator(
          onRefresh: () async {
            loadNotifyList();
          },
          child: notifications.isNotEmpty
              ? notificationsItemsBuilder()
              : emptyWidget()),
    );
  }

  //* app bar
  PreferredSizeWidget notificationsScreenAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("Unseen Notifications (${unreadCount()})"),
      actions: isSelectionMood
          ? [
              IconButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex.clear();
                      isSelectionMood = false;
                    });
                  },
                  icon: const Icon(Icons.close)),
              IconButton(
                  onPressed: () {
                    showLoadingDialog(context);
                    _notificationsServices
                        .deleteItems(items: prepareListForDelete())
                        .then((_) {
                      isSelectionMood = false;
                      selectedIndex.clear();
                      Navigator.pop(context);
                      loadNotifyList();
                    });
                  },
                  icon: const Icon(IconPack.trash)),
            ]
          : null,
    );
  }

  //* body widget
  Widget notificationsItemsBuilder() {
    return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return notificationItem(
              notification: notifications[index], index: index);
        });
  }

  //* Notification item
  Widget notificationItem(
      {required NotificationModel notification, required int index}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          if (!isSelectionMood) {
            _notificationsServices.actionForNotification(
                notify: notification, context: context);
            _notificationsServices
                .updateNotifications(notification: notification)
                .then((_) {
              setState(() {
                if (!notification.isSeen) {
                  notifications[index].isSeen = true;
                }
              });
            });
          } else {
            setState(() {
              if (selectedIndex.contains(index)) {
                selectedIndex.remove(index);
                if (selectedIndex.isEmpty) {
                  isSelectionMood = false;
                }
              } else {
                selectedIndex.add(index);
              }
            });
          }
        },
        onLongPress: () {
          switchSelectMood(index);
        },
        child: ListTile(
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              profileWidget(
                  imageUrl: notification.pfpUrl,
                  userName: notification.name,
                  size: 40),
              if (!notification.isSeen) newTag()
            ],
          ),
          title: Text(
            notification.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: notification.desc != null && notification.desc != "desc"
              ? Text(
                  notification.desc!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 14),
                )
              : null,
          trailing: isSelectionMood
              ? selectedIndex.contains(index)
                  ? selectedTag()
                  : null
              : Text(
                  ageFromTimestamp(notification.timestamp),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                ),
        ),
      ),
    );
  }

  Widget newTag() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.red),
      child: const Text(
        "New",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget selectedTag() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      child: const Icon(
        Icons.done,
        color: Colors.white,
        size: 15,
      ),
    );
  }

  Widget emptyWidget() {
    return const Column(
      children: [
        Center(
          child: Text(
            "Nothing Here yet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        )
      ],
    );
  }
}
