import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/screens/Settings/widgets/board_item.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class SavedPage extends StatefulWidget {
  final String userId;
  const SavedPage({required this.userId, super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<BoardModel> userBoards = [];
  bool isLoading = true;
  //* instances
  final BoardServices _boardServices = BoardServices();
  final AuthServices _authServices = AuthServices();
  //* functions
  void getBoardsData() {
    _boardServices
        .userBoards(
            context: context,
            userId: widget.userId,
            isUser: _authServices.checkIfItsUser(userId: widget.userId))
        .then((value) {
      setState(() {
        userBoards = hideBoard(boards: value);
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getBoardsData();
    super.initState();
  }

  List<BoardModel> hideBoard({required List<BoardModel> boards}) {
    String currentUserId = _authServices.getTheCurrentUserId();
    List<BoardModel> userVisibleBoards = [];
    for (BoardModel board in boards) {
      if (board.isSecret) {
        if (board.contributors.contains(currentUserId)) {
          userVisibleBoards.add(board);
        }
      } else {
        userVisibleBoards.add(board);
      }
    }
    return userVisibleBoards;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loadingWidget() : itemBuilder();
  }

  Widget itemBuilder() {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: userBoards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1.5, crossAxisCount: 2),
        itemBuilder: (context, index) {
          return BoardItem(
              board: userBoards[index],
              onDeleteEffect: (_) {
                setState(() {
                  getBoardsData();
                  //* i have no idea why but somehow this is the only way for the data to refresh so don't touch
                  userBoards = [];
                });
              },
              onBoardDelete: () {
                getBoardsData();
              });
        });
  }
}
