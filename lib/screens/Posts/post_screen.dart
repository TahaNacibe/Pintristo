import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/tag_model.dart';
import 'package:pintresto/screens/Posts/advanced_settings.dart';
import 'package:pintresto/screens/Posts/dialogs/borads_dialog.dart';
import 'package:pintresto/screens/Posts/dialogs/confirm_dialog.dart';
import 'package:pintresto/screens/Posts/tag_topic_screen.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/arrow_tile.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/labeld_filed.dart';
import 'package:pintresto/widgets/rounded_button.dart';

class PostScreen extends StatefulWidget {
  final String imagePath;
  final BoardModel? initialBoard;
  const PostScreen({required this.imagePath, this.initialBoard, super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //* vars
  List<TagModel> _selectedTags = [];
  Map<String, dynamic> _advancedSettingsResponse = {
    "allowComments": true,
    "showSimilarProducts": true,
    "altText": ""
  };
  BoardModel? _selectedBoard;

  //* controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  //* functions declaration
  String selectedTagsHint() {
    if (_selectedTags.isNotEmpty) {
      String unit = _selectedTags.length < 10 ? "tag" : "tags";
      return "${_selectedTags.length} $unit";
    } else {
      return "";
    }
  }

  // board select
  String selectedBoardHint() {
    if (_selectedBoard != null) {
      return _selectedBoard!.name;
    } else {
      return "";
    }
  }

  // GET board id
  String? getBoardId() {
    if (_selectedBoard != null) {
      return _selectedBoard!.boardId;
    } else {
      return null;
    }
  }

  // create the post object
  PostModel getThePost() {
    return PostModel(
        title: _titleController.text,
        description: _descriptionController.text,
        link: _linkController.text,
        boardId: getBoardId(),
        ownerId: "",
        postId: "",
        timestamp: Timestamp.now(),
        imageUrl: widget.imagePath,
        selectedTags: _selectedTags.map((tag) => tag.name).toList(),
        allowComments: _advancedSettingsResponse["allowComments"],
        altText: _advancedSettingsResponse["altText"],
        showSimilarProducts: _advancedSettingsResponse["showSimilarProducts"],
        tagsPeopleIds: [],
        hashtagsId: []);
  }

  // create post function
  void createPost() {
    showLoadingDialog(context);
    //* create the post object
    _postsServices.postPin(post: getThePost(), context: context).then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void handleExit() {
    showConfirmBottomSheet(context, "Discard the changes?", "Keep editing")
        .then((answer) {
      if (!answer) {
        Navigator.pop(context);
      }
    });
  }

  //* instances
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());

  @override
  void initState() {
    if (widget.initialBoard != null) {
      setState(() {
        _selectedBoard = widget.initialBoard;
      });
    }
    super.initState();
  }

  //* UI tree
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        handleExit();
      },
      child: Scaffold(
        appBar: postScreenAppBar(),
        //* body section
        body: bodyWidget(),
      ),
    );
  }

  //* post screen app bar
  PreferredSizeWidget postScreenAppBar() {
    return AppBar(
      title: const Text(
        "Create Pin",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            handleExit();
          },
          icon: const Icon(Icons.arrow_back_ios)),
    );
  }

  //* post screen body widget tree
  Widget bodyWidget() {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [imageDisplayForPost(), inputFields(), otherActions()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              roundedButton(icon: Icons.folder, padding: 12),
              SizedBox(
                width: 150,
                child: glowButtons(
                    horizontalPadding: 8,
                    title: "Create",
                    buttonColor: Colors.red,
                    onClick: () {
                      //* create the post
                      createPost();
                    }),
              )
            ],
          ),
        ),
      ],
    );
  }

  //* image display for posts
  Widget imageDisplayForPost() {
    //* vars
    File imagePath = File(widget.imagePath);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: FileImage(imagePath),
              width: 150,
              height: 220,
              fit: BoxFit.cover, // Added
            ),
          ),
          roundedButton(icon: Icons.refresh, padding: 8)
        ],
      ),
    );
  }

  //* title, description, link fields
  Widget inputFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          labeledTextFiled(
              hintText: "Tell everyone what your Pin is about",
              label: "Title",
              textController: _titleController),
          labeledTextFiled(
              hintText: "Add a description, mention, or hashtags to your Pin",
              label: "Description",
              textController: _descriptionController),
          labeledTextFiled(
              hintText: "Add your link here",
              label: "Link",
              textController: _linkController),
        ],
      ),
    );
  }

  //* other actions section
  Widget otherActions() {
    return Column(
      children: [
        arrowTile(
            title: "Pick a board",
            actionHint: selectedBoardHint(),
            onClick: () async {
              _selectedBoard = await selectBoardForPost(
                  context: context, initialSelect: _selectedBoard);
              setState(() {});
            }),
        arrowTile(
            title: "Tag topics",
            onClick: () async {
              _selectedTags = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TagTopicScreen(
                            initialTags: _selectedTags,
                          )));
              setState(() {});
            },
            actionHint: selectedTagsHint()),
        arrowTile(
            title: "Advanced Settings",
            onClick: () async {
              _advancedSettingsResponse = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdvancedSettings(
                            oldSettings: _advancedSettingsResponse,
                          )));
            },
            showDivider: false),
      ],
    );
  }
}
