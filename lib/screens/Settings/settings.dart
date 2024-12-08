import 'package:flutter/material.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/user_provider.dart';
import 'package:pintresto/screens/Settings/account_settings.dart';
import 'package:pintresto/screens/Settings/pages/boards_page.dart';
import 'package:pintresto/screens/Settings/pages/pins_page.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? userDetails;
  bool showData = false;
  //* instances
  final UserServices _userServices = UserServices();

  void getUserData() {
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        userDetails = user;
        showData = true;
      });
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Provide vsync here
  }

  @override
  void dispose() {
    _tabController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showData
        ? SafeArea(
            child: Scaffold(
              appBar: appBar(),
              body: TabBarView(
                controller:
                    _tabController, // Attach the controller here as well
                children: [
                  YourPinsPage(
                    user: userDetails!,
                  ), // Replace with your content
                  const BoardsPage(), // Replace with your content
                ],
              ),
            ),
          )
        : loadingWidget();
  }

  //* app bar
  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Consumer<UserProvider>(builder: (context, userProvider, child) {
        // Check if an update has happened
        if (userProvider.updateHappen) {
          getUserData();
          // userProvider.resetUpdateHappen();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountSettings(
                              pfpUrl: userDetails!.pfpUrl,
                              userName: userDetails!.userName,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: profileWidget(
                    imageUrl: userDetails!.pfpUrl,
                    userName: userDetails!.userName,
                    size: 35),
              ),
            ),
            SizedBox(
              width: 200,
              child: TabBar(
                controller: _tabController, // Attach the controller here
                indicatorColor: Theme.of(context).iconTheme.color,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(child: tabWidget(title: "Pins")),
                  Tab(child: tabWidget(title: "Boards")),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            )
          ],
        );
      }),
    );
  }

  //* tab widget
  Widget tabWidget({required String title}) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).iconTheme.color),
    );
  }
}
