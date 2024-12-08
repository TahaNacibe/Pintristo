import 'package:awesome_notifications/awesome_notifications.dart';


void createNotification(String title, String imageUrl, int id,
    {String? description}) {
  try {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        channelKey: 'basic_channel',
        title: title,
        roundedLargeIcon: true,
        body: description,
        notificationLayout: NotificationLayout.Inbox,
        largeIcon: imageUrl,
        displayOnForeground: true,
        displayOnBackground: true,
        id: id,
      ),
    );
  } catch (e) {
  }
}
