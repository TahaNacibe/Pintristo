import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Chats/chats/chat_room.dart';
import 'package:pintresto/screens/Settings/profil/content_section.dart';
import 'package:pintresto/screens/Settings/profil/edit_profile.dart';
import 'package:pintresto/screens/Settings/profil/follow_users.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';

class ProfilePage extends StatefulWidget {
  final bool isCurrentUser;
  final String userId;
  const ProfilePage({required this.isCurrentUser, this.userId = "", super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? userDetails;
  UserModel? currentUser;
  User? userEditionDetails;
  bool isLoading = true;
  //* instances
  final UserServices _userServices = UserServices();
  final AuthServices _authServices = AuthServices();
  final ChatServices _chatServices = ChatServices();
  void getUserInformation() {
    if (widget.isCurrentUser) {
      _userServices.getUserDetails(context).then((user) {
        setState(() {
          userDetails = user;
          _authServices.getTheCurrentUser().then((value) {
            userEditionDetails = value;
            isLoading = false;
          });
        });
      });
    } else {
      _userServices
          .getOtherUserDetails(userId: widget.userId, context: context)
          .then((otherUser) {
        setState(() {
          userDetails = otherUser;
          isLoading = false;
        });
      });
    }
  }

  bool isUserFollowed({required String userId}) {
    return currentUser!.followingIds.contains(userId);
  }

  void changeFollowState() {
    if (isUserFollowed(userId: widget.userId)) {
      _userServices.unFollowUser(
          followedUserId: widget.userId, context: context);
      currentUser!.followingIds.remove(widget.userId);
    } else {
      _userServices.followUser(followedUserId: widget.userId, context: context);
      currentUser!.followingIds.add(widget.userId);
    }
    setState(() {});
  }

  @override
  void initState() {
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        currentUser = user;
      });
    });
    getUserInformation();
    super.initState();
  }

  void updateUser() {
    _userServices.getUserDetails(context).then((user) {
      setState(() {
        userDetails = user;
      });
    });
  }

  Widget loadingCover(ImageChunkEvent? loadingProgress, Widget child) {
    if (loadingProgress == null) {
      // If the image is fully loaded, show it
      return child;
    } else {
      // While the image is loading, show a loading indicator
      return Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(child: loadingWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: isLoading ? loadingWidget() : appBodyWidget(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded)),
    );
  }

  //* body widget
  Widget appBodyWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userDetailsWidget(),
          //* options
          widget.isCurrentUser ? userButtonBar() : otherUsersbuttonsBar(),
          ContentSection(
            userId:
                widget.isCurrentUser ? userEditionDetails!.uid : widget.userId,
          )
        ],
      ),
    );
  }

  //* user details widget
  Widget userDetailsWidget() {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Image(
            width: MediaQuery.sizeOf(context).width,
            height: 240,
            image: NetworkImage(
              userDetails!.userCover ?? "",
            ),
            loadingBuilder: (context, child, loadingProgress) {
              return loadingCover(loadingProgress, child);
            },
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: MediaQuery.sizeOf(context).width,
                height: 240,
                color: Colors.grey.withOpacity(.3),
                child: Center(
                  child: Text(
                    userDetails!.userName[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                  0.4,
                  .7
                ],
                    colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(.7)
                ])),
          ),
          Positioned(
            top: 170,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    child: profileWidget(
                        imageUrl: userDetails!.pfpUrl,
                        userName: userDetails!.userName,
                        size: 120),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Row(
                          children: [
                            Text(
                              userDetails!.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 23),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            if (userDetails!.isVerified)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.withOpacity(.3)),
                        child: Text(
                          "# ${userDetails!.email.replaceAll("@gmail.com", "")}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      followersWidget()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //* followers widget
  Widget followersWidget() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.isCurrentUser) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FollowUsers(
                          isFollowers: true,
                          currentUser: userDetails!,
                          usersIds: userDetails!.followersIds)));
            }
          },
          child: Text(
            "${userDetails!.followersIds.length} Followers",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        Text(
          "  |  ",
          style: TextStyle(
            color: Colors.grey.withOpacity(.5),
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.isCurrentUser) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FollowUsers(
                          isFollowers: false,
                          currentUser: userDetails!,
                          usersIds: userDetails!.followingIds)));
            }
          },
          child: Text(
            "${userDetails!.followingIds.length} Following",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  //* userButton bar
  Widget userButtonBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        child: glowButtons(
            horizontalPadding: 0,
            title: "Edit Profile",
            buttonColor: Colors.red.withOpacity(.7),
            onClick: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfile(
                            coverUrl: userDetails!.userCover,
                            pfpUrl: userDetails!.pfpUrl,
                            userName: userDetails!.userName,
                            onChangesTakeEffect: () {
                              //* update user data
                              updateUser();
                            },
                          )));
            }),
      ),
    );
  }

  //* other users buttons bar
  Widget otherUsersbuttonsBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: glowButtons(
                horizontalPadding: 0,
                title: isUserFollowed(userId: widget.userId)
                    ? "UnFollow"
                    : 'Follow',
                buttonColor: isUserFollowed(userId: widget.userId)
                    ? Colors.grey.withOpacity(.7)
                    : Colors.red.withOpacity(.7),
                onClick: () {
                  changeFollowState();
                }),
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 130,
            child: glowButtons(
                horizontalPadding: 0,
                title: 'Message',
                buttonColor: Colors.grey.withOpacity(.3),
                onClick: () {
                  _chatServices
                      .isChatRoomExist(
                          context: context,
                          userId: currentUser!.userId,
                          otherId: widget.userId)
                      .then((result) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatRoom(
                                chatId: result['chatId'],
                                isBlocked: result['isBlocked'],
                                receiverName: userDetails!.userName,
                                receiverPfp: userDetails!.pfpUrl)));
                  });
                }),
          ),
        ],
      ),
    );
  }
}
