import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/loading_screen.dart';
import 'package:pintresto/providers/notifications/notifications_manager.dart';
import 'package:pintresto/providers/theme_providers.dart';
import 'package:pintresto/providers/user_provider.dart';
import 'package:pintresto/theme/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Ensure SharedPreferences is initialized
  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(
    // Set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      ),
    ],
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
});

  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher);

  // Register a periodic task (adjust the frequency as needed)
  Workmanager().registerPeriodicTask(
    '1', // Unique ID for the task
    'fetchNotifications', // Task name
    frequency:
        const Duration(minutes: 15), // Adjust this based on your requirements
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), // Register UserProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          // Switch between light and dark themes based on isDarkTheme
          theme: themeProvider.isDarkTheme
              ? AppThemes.darkTheme
              : AppThemes.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const LoadingScreen(), // Initial screen
        );
      },
    );
  }
}

