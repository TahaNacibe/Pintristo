import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/Posts/dialogs/create_bord_dialog.dart';
import 'package:pintresto/screens/Posts/widgets/board_tile.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/rounded_button.dart';

//* board select widget
Future<BoardModel?> selectBoardForPost(
    {required BuildContext context, required BoardModel? initialSelect}) async {
  return await showModalBottomSheet<BoardModel>(
    context: context,
    builder: (context) {
      return BoardDialog(
        initialBoard: initialSelect,
      );
    },
  );
}

class BoardDialog extends StatefulWidget {
  final BoardModel? initialBoard;
  const BoardDialog({required this.initialBoard, super.key});

  @override
  State<BoardDialog> createState() => _BoardDialogState();
}

class _BoardDialogState extends State<BoardDialog> {
  //* function declaration
  void onExit() {
    if (widget.initialBoard != null) {
      Navigator.of(context).pop(widget.initialBoard);
    } else {
      Navigator.of(context).pop(null);
    }
  }

  bool isItSelected({required BoardModel item}) {
    if (widget.initialBoard != null) {
      if (widget.initialBoard!.name == item.name) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //*
  void onExitOnSelect({required BoardModel selectedBoard}) {
    if (widget.initialBoard != null) {
      if (widget.initialBoard!.name == selectedBoard.name) {
        Navigator.of(context).pop(null);
      } else {
        Navigator.of(context).pop(selectedBoard);
      }
    } else {
      Navigator.of(context).pop(selectedBoard);
    }
  }

//
  Future<void> getBoardCover({required List<BoardModel> userBoardsList}) async {
    for (BoardModel board in userBoardsList) {
      PostModel? post =
          await _postsServices.getPostById(postId: board.postsIds.firstOrNull,context: context);
      if (post != null) {
        images.add(post.imageUrl);
      } else {
        images.add("pass");
      }
    }
    isLoading = false;
    setState(() {});
  }

//* vars
  BoardModel? boardCreateResponse;
  List<BoardModel> userBoards = [];
  List<String> images = [];
  bool isLoading = true;

//* instances
  final PostsServices _postsServices = PostsServices(userServices: UserServices());
  final AuthServices _authServices = AuthServices();
  final BoardServices _boardServices = BoardServices();
//* init
  @override
  void initState() {
    _boardServices
        .userBoards(userId: _authServices.getTheCurrentUserId(), isUser: true,context: context)
        .then((boardsList) {
      setState(() {
        userBoards = boardsList;
        getBoardCover(userBoardsList: boardsList);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* control row
        controlRow(context, onExit: () => onExit()),
        //* boards builder
        itemDisplay(),
        //* create new board
        InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              boardCreateResponse = await showCreateBoardBottomSheet(context);
              if (boardCreateResponse != null) {
                setState(() {
                  userBoards.add(boardCreateResponse!);
                  images.add("pass");
                });
              }
            },
            child: createNewBoard()),
      ],
    );
  }

  //* board control row
  Widget controlRow(BuildContext context, {required VoidCallback onExit}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                onExit();
              },
              icon: const Icon(
                Icons.close,
                size: 35,
              )),
          const Expanded(
              child: Padding(
            padding: EdgeInsets.only(right: 50),
            child: Center(
              child: Text(
                "Save to board",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ))
        ],
      ),
    );
  }

//* itemsDisplay
  Widget itemDisplay() {
    return isLoading
        ? Expanded(child: loadingWidget())
        : userBoards.isNotEmpty
            ? boardsItemsBuilder(youBoards: userBoards, context: context)
            : emptyListDisplay();
  }

//* empty widget display
  Widget emptyListDisplay() {
    return const Expanded(
        child: Center(
      child: Text(
        "No boards yet\nStart by creating a new board",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
      ),
    ));
  }

//* items list builder
  Widget boardsItemsBuilder({
    required List<BoardModel> youBoards,
    required BuildContext context,
  }) {
    //* ui tree
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: youBoards.length,
            itemBuilder: (context, index) {
              //* vars declare
              BoardModel board = youBoards[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    onExitOnSelect(selectedBoard: board);
                  },
                  child: boardItemWidget(
                      title: board.name,
                      firstImage: images[index],
                      isSelectedItem: isItSelected(item: board)),
                ),
              );
            }),
      ),
    );
  }

//* new item widget create
  Widget createNewBoard() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 20),
      child: Row(
        children: [
          roundedButton(icon: Icons.add, padding: 12),
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              "Create board",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}
