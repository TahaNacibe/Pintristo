import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pintresto/screens/Chats/chats/image_view.dart';
import 'package:pintresto/services/chat_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class ChatMedia extends StatefulWidget {
  final String chatId;
  const ChatMedia({required this.chatId, super.key});

  @override
  State<ChatMedia> createState() => _ChatMediaState();
}

class _ChatMediaState extends State<ChatMedia> {
  //* instances
  final ChatServices _chatServices = ChatServices();

  //* vars
  List<String> mediaUrls = [];
  bool isLoading = true;

  //* functions
  void loadChatMedia() {
    _chatServices
        .fetchAllImageUrls(context: context, chatId: widget.chatId)
        .then((urls) {
      mediaUrls = urls;
      isLoading = false;
      setState(() {});
    });
  }

  //* init
  @override
  void initState() {
    loadChatMedia();
    super.initState();
  }

  //* ui tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMediaPage(),
      body: isLoading ? loadingWidget() : imagesDisplayBuilder(),
    );
  }

  //* app bar
  PreferredSizeWidget appBarMediaPage() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded)),
      title: Text("Media"),
    );
  }

  //* image builder
  Widget imagesDisplayBuilder() {
    return MasonryGridView.count(
        itemCount: mediaUrls.length,
        crossAxisCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageView(
                              url: mediaUrls[index],
                            )));
              },
              child: mediaItem(url: mediaUrls[index]));
        });
  }

  //* media item
  Widget mediaItem({required String url}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image(
          image: NetworkImage(url),
          errorBuilder: (context, error, stackTrace) {
            return errorImageDisplay();
          },
          loadingBuilder: (context, child, loadingProgress) {
            return loadingForImage(loadingProgress, child);
          },
        ),
      ),
    );
  }

  //* loading widget
  Widget loadingForImage(ImageChunkEvent? loadingProgress, Widget child) {
    if (loadingProgress == null) {
      return child;
    } else {
      return Center(child: loadingWidget());
    }
  }

  //* error widget
  Widget errorImageDisplay() {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.withOpacity(.3)),
      child: Center(
        child: Text(
          "(0u0?)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
