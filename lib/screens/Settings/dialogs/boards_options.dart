import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/loading_box.dart';
import 'package:pintresto/icons/icon_pack_icons.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/screens/Settings/dialogs/confirm_dialog.dart';
import 'package:pintresto/screens/Settings/dialogs/select_pin.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/widgets/option_button.dart';

class BoardsOptions extends StatefulWidget {
  final bool isSecret;
  final List<String> alreadyInPosts;
  final String boardName;
  final void Function() refresh;
  final void Function() onBoardDelete;
  final void Function(List<PostModel> postsList) onPinsAdded;
  final String boardId;
  const BoardsOptions(
      {required this.isSecret,
      required this.boardName,
      required this.boardId,
      required this.alreadyInPosts,
      required this.refresh,
      required this.onBoardDelete,
      required this.onPinsAdded,
      super.key});

  @override
  State<BoardsOptions> createState() => _BoardsOptionsState();
}

class _BoardsOptionsState extends State<BoardsOptions> {
  BoardServices _boardServices = BoardServices();
  AuthServices _authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use min to take only necessary space
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Board Settings",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
          ),
          optionText(
              text: widget.isSecret ? "Make Board public" : "Make board secret",
              icon: widget.isSecret ? Icons.visibility : Icons.visibility_off,
              onClick: () {
                _boardServices
                    .changeBoardVisibility(
                        context: context, boardId: widget.boardId)
                    .then((_) {
                  widget.refresh();
                  Navigator.pop(context);
                });
              }),
          optionText(
              text: "Add Pin to ${widget.boardName}",
              icon: Icons.folder,
              onClick: () {
                showBottomSheetToAddPins(
                    context, widget.boardId, widget.alreadyInPosts, (newItems) {
                  widget.onPinsAdded(newItems);
                });
              }),
          optionText(
              text: "Delete ${widget.boardName}",
              icon: IconPack.trash,
              onClick: () {
                showConfirmBottomSheetForBoardDelete(context,"You won't be able to access or recover ${widget.boardName} if you delete it!").then((answer) {
                  if (answer) {
                    showLoadingDialog(context);
                    _boardServices
                        .deleteBoard(
                            context: context,
                            boardId: widget.boardId,
                            userId: _authServices.getTheCurrentUserId())
                        .then((_) {
                      widget.onBoardDelete();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  } else {
                    Navigator.pop(context);
                  }
                });
              }),
        ],
      ),
    );
  }


}

void showOptionsForBoards(
    BuildContext context,
    String boardName,
    bool isSecret,
    String boardId,
    List<String> alreadyInPosts,
    void Function() refresh,
    void Function() onBoardDelete,
    void Function(List<PostModel> postsList) onPinsAdded) {
  showModalBottomSheet(
    isScrollControlled: true, // Allow the bottom sheet to be scrollable
    context: context,
    builder: (context) {
      return BoardsOptions(
          boardName: boardName,
          isSecret: isSecret,
          boardId: boardId,
          refresh: refresh,
          alreadyInPosts: alreadyInPosts,
          onPinsAdded: onPinsAdded,
          onBoardDelete: onBoardDelete);
    },
  );
}
