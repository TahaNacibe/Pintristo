import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/screens/Chats/chats/chat_media.dart';
import 'package:pintresto/screens/Settings/dialogs/confirm_dialog.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/widgets/option_button.dart';

class ChatOptions extends StatefulWidget {
  final String receiverName;
  final String chatId;
  final String receiverId;
  final bool isBlocked;
  final void Function(String url) onBgChange;
  final VoidCallback onRefresh;
  final VoidCallback onBlockStateChange;
  const ChatOptions(
      {required this.receiverName,
      required this.chatId,
      required this.receiverId,
      required this.onBgChange,
      required this.onRefresh,
      required this.isBlocked,
      required this.onBlockStateChange,
      super.key});

  @override
  State<ChatOptions> createState() => _ChatOptionsState();
}

class _ChatOptionsState extends State<ChatOptions> {
  //* instances
  ChatServices _chatServices = ChatServices();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Chat Options",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
        optionText(
            text:
                "${widget.isBlocked ? "UnBlock" : "Block"} ${widget.receiverName}",
            icon: Icons.person_2_rounded,
            onClick: () {
              _chatServices
                  .blockUserInChat(
                      context: context,
                      chatId: widget.chatId,
                      isBlocked: widget.isBlocked,
                      otherUserId: widget.receiverId)
                  .then((_) {
                widget.onBlockStateChange();
                Navigator.pop(context);
              });
            }),
        optionText(
            text: "Delete chat",
            icon: IconPack.trash,
            onClick: () {
              showConfirmBottomSheetForBoardDelete(context,
                      "Deleted chat can't be recovered or seen by anyone")
                  .then((answer) {
                if (answer) {
                  showLoadingDialog(context);
                  _chatServices
                      .deleteChatFromBothUsers(
                          context: context, chatId: widget.chatId)
                      .then((_) {
                    widget.onRefresh();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                }
              });
            }),
        optionText(
            text: "Change chat backGround",
            icon: Icons.wallpaper_rounded,
            onClick: () {
              showLoadingDialog(context);
              _chatServices
                  .updateChatBackGroundImage(
                      context: context, chatId: widget.chatId)
                  .then((url) {
                if (url != null) {
                  widget.onBgChange(url);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                }
              });
            }),
        optionText(
            text: "Media",
            icon: Icons.perm_media_rounded,
            onClick: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatMedia(
                            chatId: widget.chatId,
                          )));
            }),
      ],
    );
  }
}

void showChatOptionsSheet(
    BuildContext context,
    String receiverName,
    String receiverId,
    bool isBlocked,
    String chatId,
    void Function(String url) onBgChange,
    VoidCallback onRefresh,
    VoidCallback onBlockStateChange) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ChatOptions(
              receiverName: receiverName,
              receiverId: receiverId,
              isBlocked: isBlocked,
              chatId: chatId,
              onRefresh: onRefresh,
              onBlockStateChange: onBlockStateChange,
              onBgChange: onBgChange),
        );
      });
}
