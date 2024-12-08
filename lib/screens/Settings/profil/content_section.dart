import 'package:flutter/material.dart';
import 'package:pintresto/screens/Settings/profil/created_page.dart';
import 'package:pintresto/screens/Settings/profil/saved_page.dart';
import 'package:pintresto/services/get_user_pins.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class ContentSection extends StatefulWidget {
  final String userId;
  const ContentSection({required this.userId, super.key});

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  Map<String, dynamic> userPosts = {};
  bool isLoading = true;
  //* instances
  @override
  void initState() {
    GetUserPins()
        .getUserPins(userId: widget.userId, context: context)
        .then((value) {
      setState(() {
        userPosts = value;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? loadingWidget()
        : DefaultTabController(
            length: 2, // Number of tabs
            child: Column(
              children: [
                TabBar(
                  dividerColor: Colors.transparent,
                  indicatorColor: Theme.of(context).iconTheme.color,
                  tabs: [
                    Tab(
                      child: Text(
                        "Created",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Theme.of(context).iconTheme.color),
                      ),
                    ), // First tab
                    Tab(
                        child: Text(
                      'Saved',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Theme.of(context).iconTheme.color),
                    )), // Second tab
                  ],
                ),
                // Wrap TabBarView with Expanded or Flexible for layout control
                SizedBox(
                  height: MediaQuery.sizeOf(context).height / 2.1,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: CreatedPinsPage(
                          posts: userPosts,
                        ),
                      ), // First tab content
                      SavedPage(
                        userId: widget.userId,
                      ), // Second tab content
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
