import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/services/image_picker.dart';

class ChatInput extends StatefulWidget {
  final String chatId;
  final String userId;
  final String senderName;
  final String senderPfp;
  const ChatInput(
      {required this.chatId,
      required this.userId,
      required this.senderName,
      required this.senderPfp,
      super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final ChatServices _chatSer = ChatServices();
  TextEditingController messageController = TextEditingController();
  List<String?> images = [];
  InputBorder messageFiledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(color: Colors.transparent, width: 0),
  );
  @override
  Widget build(BuildContext context) {
    return messageBar();
  }

  //* message bar
  Widget messageBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 75,
                child: ListView.builder(
                    itemCount: images.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 75,
                                height: 75,
                                child: Image(
                                  image: FileImage(
                                    File(images[index]!),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                images.removeAt(index);
                              });
                            },
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withOpacity(.5)),
                                child: const Icon(Icons.close)),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          TextField(
            controller: messageController,
            onSubmitted: (_) {
              if (messageController.text.isNotEmpty) {
                _chatSer.sendMessage(
                    context: context,
                    chatId: widget.chatId,
                    senderName: widget.senderName,
                    senderPfp: widget.senderPfp,
                    senderId: widget.userId,
                    message: messageController.text,
                    images: images);
                messageController.clear();
                images.clear();
              }
            },
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              prefixIcon: IconButton(
                onPressed: () {
                  ImageServices().pickImages().then((value) {
                    setState(() {
                      images = value;
                    });
                  });
                },
                icon: const Icon(Icons.camera),
              ),
              suffixIcon: messageController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        if(messageController.text.isNotEmpty){
                        _chatSer.sendMessage(
                            context: context,
                            chatId: widget.chatId,
                            senderName: widget.senderName,
                            senderPfp: widget.senderPfp,
                            senderId: widget.userId,
                            message: messageController.text,
                            images: images);
                        messageController.clear();
                        setState(() {
                          images.clear();
                        });

                        }
                      },
                      icon: const Icon(Icons.send),
                    )
                  : null,
              contentPadding: const EdgeInsets.only(left: 8),
              fillColor: Colors.grey.withOpacity(.2),
              filled: true,
              hintText: "Type a message...",
              border: messageFiledBorder,
              focusedBorder: messageFiledBorder,
              enabledBorder: messageFiledBorder,
            ),
          ),
        ],
      ),
    );
  }
}
