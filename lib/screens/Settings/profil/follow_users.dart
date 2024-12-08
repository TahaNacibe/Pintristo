import 'package:flutter/material.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';

class FollowUsers extends StatefulWidget {
  final bool isFollowers;
  UserModel currentUser;
  final List<String> usersIds;
  FollowUsers(
      {required this.isFollowers,
      required this.usersIds,
      required this.currentUser,
      super.key});

  @override
  State<FollowUsers> createState() => _FollowUsersState();
}

class _FollowUsersState extends State<FollowUsers> {
  bool isLoading = true;
  List<UserModel?> users = [];
  //* instances
  final UserServices _userServices = UserServices();
  Future<void> getUserData() async {
    for (String id in widget.usersIds) {
      UserModel? user = await _userServices.getOtherUserDetails(userId: id,context: context);
      users.add(user);
    }
    isLoading = false;
    setState(() {});
  }

  bool isUserFollowed(String userId) {
    return widget.currentUser.followingIds.contains(userId);
  }

  void updateOnClick({required String id}) {
    if (widget.currentUser.followingIds.contains(id)) {
      _userServices.unFollowUser(followedUserId: id, context: context);
      widget.currentUser.followingIds.remove(id);
    } else {
      _userServices.followUser(followedUserId: id, context: context);
      widget.currentUser.followingIds.add(id);
    }
    setState(() {});
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: isLoading ? loadingWidget() : itemBuilder(),
    );
  }

  //* appBar
  PreferredSizeWidget appBar() {
    return AppBar(
      title: Text(
        widget.isFollowers ? "Followers" : "Following",
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_rounded)),
    );
  }

  //* item builder for following
  Widget itemBuilder() {
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                isCurrentUser: users[index]!.userId ==
                                    widget.currentUser.userId,
                                userId: users[index]!.userId,
                              )));
                },
                child: itemForFollowing(user: users[index]!)),
          );
        });
  }

  //* item for following
  Widget itemForFollowing({required UserModel user}) {
    bool isFollowed = isUserFollowed(user.userId);
    return ListTile(
      leading: profileWidget(
          imageUrl: user.pfpUrl, userName: user.userName, size: 50),
      title: Text(
        user.userName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      trailing: SizedBox(
        width: 140,
        child: glowButtons(
            horizontalPadding: 0,
            title: isFollowed ? "Followed" : "Follow",
            buttonColor: isFollowed
                ? Colors.grey.withOpacity(.3)
                : Colors.red.withOpacity(.7),
            onClick: () {
              updateOnClick(id: user.userId);
            }),
      ),
    );
  }
}
