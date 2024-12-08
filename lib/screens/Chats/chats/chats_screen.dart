import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/chat_model.dart';
import 'package:pintresto/screens/Chats/chats/chat_room.dart';
import 'package:pintresto/screens/Chats/chats/dilaogs/following_list.dart';
import 'package:pintresto/screens/Chats/chats/widgets/contant_item.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatServices _chatService = ChatServices();
  final AuthServices _authServices = AuthServices();
  List<Map<String, dynamic>> usersYouFollow = [];
  List<ChatModel> userChats = [];
  List<String> lastMessages = [];
  bool isLoading = true;
  String? userId;

  //* functions
  void getChats() {
    _chatService.userChats(context).then((result) {
      setState(() {
        userChats = result;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getChats();
    userId = _authServices.getTheCurrentUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Inbox"),
        ),
        body: isLoading ? loadingWidget() : chatsScreenBody(),
      ),
    );
  }

  Widget chatsScreenBody() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          getChats();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contacts",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: userChats.length + 1,
                itemBuilder: (context, index) {
                  if (index < userChats.length) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                      chatId: userChats[index].chatId,
                                      isBlocked: userChats[index]
                                          .blocked
                                          .contains(userId),
                                      receiverName:
                                          userChats[index].receiverName,
                                      receiverPfp:
                                          userChats[index].receiverPfp!,
                                      refresh: () {
                                        getChats();
                                      },
                                    )));
                      },
                      child: contactItem(
                          pfpUrl: userChats[index].receiverPfp,
                          name: userChats[index].receiverName,
                          lastMessage: userChats[index].lastMessage),
                    );
                  } else {
                    return newItemWidget();
                  }
                })
          ],
        ),
      ),
    );
  }

  //* contact item
  Widget newItemWidget() {
    return GestureDetector(
      onTap: () {
        showUsersYouFollowBottomSheet(context, () {
          getChats();
          Navigator.pop(context);
        });
      },
      child: ListTile(
        leading: ClipOval(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(.3)),
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
        title: const Text(
          "Invite your friends",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        subtitle: const Text(
          "Connect to start chatting",
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
        ),
      ),
    );
  }
}
