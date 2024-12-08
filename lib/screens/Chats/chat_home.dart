import 'package:flutter/material.dart';
import 'package:pintresto/screens/Chats/chats/chats_screen.dart';
import 'package:pintresto/screens/Chats/updates/notification_display.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> with TickerProviderStateMixin {
  //* controllers
  late TabController _tabController;

  //* init
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  //* dispose
  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                indicatorColor: Theme.of(context).iconTheme.color,
                indicatorWeight: 3.0, // Set the weight of the indicator
                indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 20), // Adjust this value to fit your needs
                controller: _tabController,
                tabs: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tab(
                        child: SizedBox(
                          width: 100, // Set a fixed width for the tabs
                          child: Text(
                            "Updates",
                            textAlign: TextAlign
                                .center, // Center text within the container
                            style: TextStyle(
                              color: Theme.of(context).iconTheme.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Tab(
                        child: SizedBox(
                          width: 100, // Set a fixed width for the tabs
                          child: Text(
                            "Chats",
                            textAlign: TextAlign
                                .center, // Center text within the container
                            style: TextStyle(
                              color: Theme.of(context).iconTheme.color,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            NotificationDisplay(),
            ChatsScreen(),
          ],
        ),
      ),
    );
  }
}
