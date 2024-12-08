import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/screens/Chats/chats/widgets/contant_item.dart';
import 'package:pintresto/services/chat_services.dart';

class FollowingList extends StatefulWidget {
  final VoidCallback onChatCreated;
  const FollowingList({required this.onChatCreated, super.key});

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  final ChatServices _chatService = ChatServices();
  List<Map<String, dynamic>> usersYouFollow = [];
  @override
  void initState() {
    _chatService.getFollowedUsers(context).then((result) {
      setState(() {
        usersYouFollow = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: usersYouFollow.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = usersYouFollow[index];
            return GestureDetector(
              onTap: () {
                showLoadingDialog(context);
                _chatService
                    .createChatRoom(
                        receiverId: user["userId"], context: context)
                    .then((_) {
                  widget.onChatCreated();
                  Navigator.pop(context);
                });
              },
              child: contactItem(
                  pfpUrl: user["pfpUrl"],
                  name: user["userName"],
                  lastMessage: null),
            );
          }),
    );
  }
}

void showUsersYouFollowBottomSheet(
    BuildContext context, VoidCallback onChatCreated) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return FollowingList(
          onChatCreated: onChatCreated,
        );
      });
}
