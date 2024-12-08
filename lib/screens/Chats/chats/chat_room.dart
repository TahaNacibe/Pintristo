import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/message_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Chats/chats/chat_options.dart';
import 'package:pintresto/screens/Chats/chats/widgets/chat_input.dart';
import 'package:pintresto/screens/Chats/chats/widgets/message_body.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/shared/shared_vars.dart';
import 'package:pintresto/widgets/error_future.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';

class ChatRoom extends StatefulWidget {
  final String receiverName;
  final String receiverPfp;
  bool isBlocked;
  final VoidCallback? refresh;
  final String chatId;

  ChatRoom({
    required this.receiverName,
    required this.receiverPfp,
    required this.chatId,
    required this.isBlocked,
    this.refresh,
    super.key,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  //* instances
  final ChatServices _chatSer = ChatServices();
  final AuthServices _authServices = AuthServices();
  final UserServices _userServices = UserServices();

  //* controllers
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  //* vars
  String? userId;
  int limit = 7; // Start with 8 messages
  bool isLoadingMore = false;
  UserModel? senderData;
  String? chatBg;

  //* functions
  String getOtherUserId() {
    List<String> idsParts = widget.chatId.split("_");
    if (idsParts[0] != userId!) {
      return idsParts[0];
    } else {
      return idsParts[1];
    }
  }

  @override
  void initState() {
    _authServices.getTheCurrentUser().then((value) {
      setState(() {
        userId = value!.uid;
      });
    });
    _userServices.getUserDetails(context).then((userDetails) {
      setState(() {
        senderData = userDetails;
      });
    });
    _chatSer.chatBg(chatId: widget.chatId).then((bg) {
      setState(() {
        chatBg = bg;
      });
    });
    isInChat = true;
    roomId = widget.chatId;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: chatAppBar(),
      body: chatBodyPage(),
    );
  }

  //* chat room appBar
  PreferredSizeWidget chatAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          isInChat = false;
          roomId = "";
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(
                        isCurrentUser: false,
                        userId: getOtherUserId(),
                      )));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            profileWidget(
              imageUrl: widget.receiverPfp,
              userName: widget.receiverName,
              size: 40,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              widget.receiverName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
            )
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            showChatOptionsSheet(context, widget.receiverName, getOtherUserId(),
                widget.isBlocked, widget.chatId, (url) {
              setState(() {
                chatBg = url;
              });
            }, () {
              if (widget.refresh != null) {
                widget.refresh!();
                Navigator.pop(context);
              }
            }, () {
              setState(() {
                widget.isBlocked = !widget.isBlocked;
              });
            });
          },
          icon: const Icon(Icons.more_horiz_outlined),
        ),
      ],
    );
  }

  //* chat body
  Widget chatBodyPage() {
    return Container(
      decoration: BoxDecoration(
        image: chatBg != null
            ? DecorationImage(
                image: NetworkImage(chatBg!), fit: BoxFit.cover, opacity: .5)
            : null,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [messagesDisplay(), inputFiledSection()],
      ),
    );
  }

  //* input filed section
  Widget inputFiledSection() {
    return widget.isBlocked
        ? blockedDisplay()
        : ChatInput(
            chatId: widget.chatId,
            userId: userId!,
            senderName: senderData!.userName,
            senderPfp: senderData!.pfpUrl,
          );
  }

  //* blocked message
  Widget blockedDisplay() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "You can't send messages in this chat, ...",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
    );
  }

  //* messages display
  Widget messagesDisplay() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: StreamBuilder<List<MessageModel>>(
        stream: _chatSer.getMessagesStream(
            chatId: widget.chatId, limit: limit, context: context),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.waiting) {
            return loadingWidget();
          } else if (stream.connectionState == ConnectionState.none) {
            return errorWidget(text: "Error loading messages");
          } else {
            if (stream.data != null && stream.data!.isNotEmpty) {
              int totalMessages = stream.data!.length;

              // Limit the display to 8 messages per page
              List<MessageModel> paginatedMessages = stream.data!.sublist(
                (totalMessages - 8).clamp(0, totalMessages),
                totalMessages,
              );

              return SingleChildScrollView(
                controller: _scrollController,
                reverse:
                    false, // Newer messages will now be shown at the bottom
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Show "Show Older" button at the bottom if there are more than 8 messages
                      if (totalMessages > limit)
                        buttonsOfActions(
                          name: "Show Older",
                          icon: Icons.keyboard_arrow_up,
                          onClick: () {
                            setState(() {
                              limit += 7; // Load 8 older messages
                            });
                          },
                        ),
                      messagesBuilder(
                          paginatedMessages), // Display only 8 messages at a time
                      // Show "Show Newer" button at the bottom if there are more messages than the limit
                      if (limit > 7 && totalMessages > 7)
                        buttonsOfActions(
                          name: "Show Newer",
                          icon: Icons.keyboard_arrow_down,
                          onClick: () {
                            setState(() {
                              limit -= 7; // Load 8 newer messages
                            });
                          },
                        ),
                    ],
                  ),
                ),
              );
            } else {
              return errorWidget(text: "No messages to show");
            }
          }
        },
      ),
    );
  }

  //* messages builder
  Widget messagesBuilder(List<MessageModel> data) {
    return ListView.builder(
      shrinkWrap: true,
      reverse: true, // Messages display from bottom to top
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        MessageModel message = data[index];
        return MessageBody(
          userId: userId!,
          userName: widget.receiverName,
          isDeleted: message.isDeleted,
          onDelete: () {
            _chatSer.deleteMessage(
                chatId: widget.chatId,
                messageId: data[index].messageId ?? "",
                context: context);
            Navigator.pop(context);
          },
          userPfp: widget.receiverPfp,
          imagesUrl: message.imageUrl,
          ownerId: message.senderId,
          message: message.message,
          timestamp: message.timestamp,
        );
      },
    );
  }

  Widget buttonsOfActions({
    required String name,
    required IconData icon,
    required VoidCallback onClick,
  }) {
    return TextButton(
      onPressed: onClick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          Icon(icon, color: Theme.of(context).iconTheme.color),
        ],
      ),
    );
  }
}
