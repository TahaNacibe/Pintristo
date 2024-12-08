import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/providers/notifications/notifications_services.dart';
import 'package:pintresto/providers/user_provider.dart';
import 'package:pintresto/screens/Chats/chat_home.dart';
import 'package:pintresto/screens/ForYouPage/for_you.dart';
import 'package:pintresto/screens/Posts/new_post.dart';
import 'package:pintresto/screens/Search/search_screen.dart';
import 'package:pintresto/screens/Settings/settings.dart';
import 'package:pintresto/services/network_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/no_network_screen.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //* display var's
  List<Widget> pages = [
    // for you page
    const ForYouPage(),
    // search page
    const SearchScreen(),
    // chat page
    const ChatHome(),
    // profile page
    const SettingsScreen(),
  ];
  UserModel? userDetails;
  bool isLoading = true;
  bool isOnline = true;

  //* control vars
  int _navBarIndex = 0;
  int _pageIndex = 0;

  //* instances
  final NotificationsServices _notificationsServices =
      NotificationsServices(userServices: UserServices());
  final ConnectivityServices _connectivityServices = ConnectivityServices();
  final UserServices _userServices = UserServices();

  //* functions declarations
  void changePage({required int i}) {
    setState(() {
      // update active index for navbar
      // if it's less then 2 update page index with it
      if (i < 2) {
        _pageIndex = i;
        _navBarIndex = i;
        // else if it's bigger then 2 go back one step to fill the add button gap
      } else if (i > 2) {
        _pageIndex = i - 1;
        _navBarIndex = i;
      } else {
        showPostBottomSheet(context);
      }
    });
  }

  void getUserDetails() {
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        userDetails = user;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    _connectivityServices.isConnected().then((result) {
      setState(() {
        isOnline = result;
      });
    });
    getUserDetails();
    _notificationsServices
        .listenForNotifications(context); // Start listening for notifications
    super.initState();
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    // Set the status bar color to match the Scaffold's background color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context)
          .scaffoldBackgroundColor, // Change to your Scaffold color
    ));
    return Scaffold(
      body: mainBody(),
      bottomNavigationBar: isLoading ? Container() : bottomNavBar(),
    );
  }

  //* main body widget
  Widget mainBody() {
    return isOnline
        ? pages[_pageIndex]
        : NoNetworkScreen(
            onCheck: (state) {
              setState(() {
                isOnline = state;
              });
            },
          );
  }

  //* navBar
  Widget bottomNavBar() {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      // Check if an update has happened
      if (userProvider.updateHappen) {
        getUserDetails();
        // userProvider.resetUpdateHappen();
      }
      return SalomonBottomBar(
        currentIndex: _navBarIndex,
        onTap: (i) => changePage(i: i),
        items: [
          //? Home
          SalomonBottomBarItem(
            icon: const Icon(IconPack.home, size: 20),
            title: const Text("Home"),
            selectedColor: Colors.purple,
          ),

          //? Search
          SalomonBottomBarItem(
            icon: const Icon(IconPack.search, size: 20),
            title: const Text("Search"),
            selectedColor: Colors.indigo,
          ),

          //? new Post
          SalomonBottomBarItem(
            icon: const Icon(Icons.add, size: 20),
            title: const Text("Post"),
            selectedColor: Colors.orange,
          ),

          //? Chat
          SalomonBottomBarItem(
            icon: const Icon(IconPack.chat, size: 20),
            title: const Text("Chats"),
            selectedColor: Colors.teal,
          ),

          //? Profile
          SalomonBottomBarItem(
            icon: profileWidget(
                imageUrl: userDetails!.pfpUrl,
                userName: userDetails!.userName,
                size: 30),
            title: Text(userDetails!.userName),
            selectedColor: Colors.grey,
          ),
        ],
      );
    });
  }
}
