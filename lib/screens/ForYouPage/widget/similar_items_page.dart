import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/widgets/error_future.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/pin_item.dart';

class SimilarItemsPage extends StatefulWidget {
  final List<String> tags;
  final String postId;
  final PostsServices postServices;
  const SimilarItemsPage(
      {required this.tags,
      required this.postServices,
      required this.postId,
      super.key});

  @override
  State<SimilarItemsPage> createState() => _SimilarItemsPageState();
}

class _SimilarItemsPageState extends State<SimilarItemsPage> {
  List<PostModel>? _posts; // Stores the fetched posts
  bool _isLoading = true; // Tracks loading state
  String? _errorMessage; // Stores error message

  @override
  void initState() {
    super.initState();
    _fetchSimilarItems();
  }

  //* Fetch similar items from the post service
  Future<void> _fetchSimilarItems() async {
    try {
      List<PostModel> posts =
          await widget.postServices.getPostsWithTagsAndTitle(
        context: context,
        tags: widget.tags,
        postIdToIgnore: widget.postId,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return loadingWidget(); // Show loading widget while fetching
    } else if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!)); // Show error message if an error occurred
    } else if (_posts == null || _posts!.isEmpty) {
      return errorWidget(
          text: "No posts available"); // Show message if no posts are found
    } else {
      return customTwoColumnBuilder(posts: _posts!); // Display posts
    }
  }
}
