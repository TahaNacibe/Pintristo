import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pintresto/screens/Chats/chats/dilaogs/messages_options.dart';
import 'package:pintresto/screens/Chats/chats/widgets/image_display.dart';
import 'package:pintresto/services/time_services.dart';

class MessageBody extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPfp;
  final String ownerId;
  final String message;
  final bool isDeleted;
  final List<String?>? imagesUrl;
  final void Function() onDelete;
  final Timestamp timestamp;
  const MessageBody({
    super.key,
    required this.userId,
    required this.userName,
    required this.userPfp,
    required this.ownerId,
    required this.message,
    required this.onDelete,
    required this.isDeleted,
    required this.imagesUrl,
    required this.timestamp,
  });

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  bool isExpend = false;
  String getTimeForMessage({required Timestamp timestamp}) {
    return timeSince(timestamp);
  }

  bool isUser({required String id}) {
    return id == widget.userId;
  }

  BoxDecoration senderDecoration = BoxDecoration(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        topLeft: Radius.circular(20),
        bottomRight: Radius.circular(8),
        bottomLeft: Radius.circular(20),
      ),
      color: Colors.red.withOpacity(.7));
  BoxDecoration receiverDecoration = BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      color: Colors.grey.withOpacity(.5));
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (!widget.isDeleted)
          showMessagesOptions(context, widget.onDelete, () {
            Navigator.pop(context);
            // Copy text to the clipboard
            Clipboard.setData(ClipboardData(text: widget.message));
            // Show a snackbar or a message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to clipboard')),
            );
          });
      },
      child: messageBody(
          ownerId: widget.ownerId,
          message: widget.message,
          timestamp: widget.timestamp),
    );
  }

  //* messages
  Widget messageBody(
      {required String ownerId,
      required String message,
      required Timestamp timestamp}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpend = !isExpend;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isUser(id: ownerId)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (widget.imagesUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: imageDisplay(urls: widget.imagesUrl!, context: context),
              ),
            Row(
              mainAxisAlignment: isUser(id: ownerId)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: isUser(id: ownerId)
                          ? senderDecoration
                          : receiverDecoration,
                      child: Column(
                        children: [
                          widget.isDeleted
                              ? Text(
                                  "[Deleted by user]",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                )
                              : Text(
                                  message,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpend)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                child: Text(
                  getTimeForMessage(timestamp: timestamp),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
              )
          ],
        ),
      ),
    );
  }
}
