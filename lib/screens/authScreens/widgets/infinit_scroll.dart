import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PinterestClone extends StatefulWidget {
  const PinterestClone({super.key});

  @override
  PinterestCloneState createState() => PinterestCloneState();
}

class PinterestCloneState extends State<PinterestClone> {
  //* List of asset images for the grid
  final List<String> _initialImages = [
    'assets/images/placeholders/1.jpg',
    'assets/images/placeholders/2.jpg',
    'assets/images/placeholders/3.jpg',
    'assets/images/placeholders/8.jpg',
    'assets/images/placeholders/4.jpg',
    'assets/images/placeholders/5.jpg',
    'assets/images/placeholders/6.jpg',
    'assets/images/placeholders/7.jpg',
    'assets/images/placeholders/8.jpg',
    'assets/images/placeholders/9.jpg',
    'assets/images/placeholders/10.jpg',
  ];

  //* display images list
  List<String> _images = [];

  //* controllers
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;

  //* vars
  double _scrollPosition = 0.0;
  final double _sizeForImagesWindow = 2.5;

  //* Define a threshold for the maximum number of images allowed
  final int _imageThreshold = 50;

  //* start the scroll as the widget is built
  @override
  void initState() {
    super.initState();

    //* Initially populate the image list
    _images = List<String>.from(_initialImages);

    //* Set up automatic scrolling every 150ms
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _autoScroll();
    });

    //* Detect when we are close to the bottom and load more images
    _scrollController.addListener(_loadMoreImages);
  }

  //* dispose of the controllers when the page is closed
  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  //* Automatically scroll the grid
  void _autoScroll() {
    if (_scrollController.hasClients) {
      // Scroll speed
      _scrollPosition += 1.5;

      //* move to the items
      _scrollController.animateTo(
        _scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  //* Load more images when we are close to the bottom
  void _loadMoreImages() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      setState(() {
        //* Check if the list exceeds the threshold
        if (_images.length >= _imageThreshold) {
          //* Remove the first half of the images to reduce memory usage
          _images.removeRange(0, _images.length ~/ 2);
        }

        //* Add more images to the list by duplicating the initial images
        _images.addAll(List<String>.from(_initialImages));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //* Limit the height to show only 2 rows
          SizedBox(
            height: MediaQuery.of(context).size.height / _sizeForImagesWindow,
            child: MasonryGridView.count(
              controller: _scrollController,
              itemCount: _images.length,

              //* 3 items per row
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemBuilder: (context, index) {
                //* item display
                return imageItemDisplay(path: _images[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  //* image Item
  Widget imageItemDisplay({required String path}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
