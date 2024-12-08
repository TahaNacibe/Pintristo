import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/services/download_services.dart';

class ImageView extends StatefulWidget {
  final String url;
  const ImageView({required this.url, super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showLoadingDialog(context);
                ImageDownloader.downloadImage(widget.url, context).then((_) {
                  Navigator.pop(context);
                });
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image(
              image: CachedNetworkImageProvider(widget.url),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
