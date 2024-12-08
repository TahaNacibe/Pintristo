import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/dialogs/fast_snackbar.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Posts/widgets/tag_widget.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/profile_image.dart';
import 'package:pintresto/widgets/switch_tile.dart';

Future<BoardModel?> showCreateBoardBottomSheet(BuildContext context) {
  //* Ui tree
  return showModalBottomSheet<BoardModel?>(
    isScrollControlled: true,
    context: context,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const CreateBoardPage();
    },
  );
}

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  //* vars
  List<String> suggests = [
    "Stuff to buy",
    "Places to visit",
    "Projects to try",
    "Things to wear",
    "Recipes to cook",
    "Ideas for the house"
  ];
  bool _isSecret = false;
  List<UserModel> followItems = [];
  List<String> selectedUsers = [];
  bool _isLoading = true;
  String? _userId;
  String? boardId;
  UserModel? userDetails;

  //* controllers
  final TextEditingController _namingController = TextEditingController();

  //* instances
  final BoardServices _boardServices = BoardServices();
  final UserServices _userServices = UserServices();
  final AuthServices _authServices = AuthServices();
  //* functions
  void _updateWithSuggest({required String suggest}) {
    setState(() {
      _namingController.text = suggest;
    });
  }

  void selectUsers({required String userId}) {
    setState(() {
      if (isUserSelected(userId: userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
  }

  bool isUserSelected({required String userId}) {
    return selectedUsers.contains(userId);
  }

  bool checkIfItUser({required String id}) {
    return _authServices.getTheCurrentUserId() == id;
  }

  // switch the secret state
  void _switchSecretState({required bool state}) {
    setState(() {
      _isSecret = state;
    });
  }

  void _onCreateButton() {
    if (_namingController.text.isNotEmpty) {
      if (_userId == null) {
        showFastSnackbar(context, "User is Not Signed in");
      } else {
        selectedUsers.add(_userId!);
        // create board logic
        _boardServices
            .createBoardInDataBase(
                userId: _userId!,
                context: context,
                boardName: _namingController.text,
                contributes: selectedUsers,
                isSecret: _isSecret)
            .then((result) {
          //
          boardCreatingLogic(result: result);
        });
      }
    }
  }

  void boardCreatingLogic({required String? result}) {
    //* update the settings
    if (result != null) {
      Navigator.of(context).pop(BoardModel(
          name: _namingController.text,
          isSecret: _isSecret,
          postsIds: [],
          boardId: result,
          cover: "",
          contributors: []));
    } else {
      showFastSnackbar(context, "Error accrued when creating the board");
    }
  }

  void getFollowingUsers({required List<String> ids}) {
    ids.removeWhere((id) => checkIfItUser(id: id));
    for (String id in ids) {
      _userServices
          .getOtherUserDetails(userId: id, context: context)
          .then((user) {
        setState(() {
          followItems.add(user!);
        });
      });
    }
  }

  //* initial
  @override
  void initState() {
    _userServices.getUserDetails(context).then((user) {
      if (user != null) {
        _userId = user.userId;
        getFollowingUsers(ids: user.followingIds);
        userDetails = user;
        _isLoading = false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //* Ui tree
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            sheetControlBar(),
            nameTheBoard(),
            suggestsRow(),
            _isLoading ? loadingWidget() : collaboratorsBoard(),
            visibilitySection(),
          ],
        ),
      ),
    );
  }

//* sheetBar
  Widget sheetControlBar() {
    //* Ui tree
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              // Return null when the user presses the close button
              Navigator.of(context).pop(null); // Dismiss without returning data
            },
            icon: const Icon(
              Icons.close,
              size: 30,
            ),
          ),
          const Text(
            "Create board",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          SizedBox(
            width: 120,
            child: glowButtons(
              horizontalPadding: 0,
              title: "Create",
              buttonColor:
                  _namingController.text.isEmpty ? Colors.grey : Colors.red,
              onClick: _onCreateButton,
            ),
          ),
        ],
      ),
    );
  }

//* name the board
  Widget nameTheBoard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Name your board",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          costumeInputFiled(
            horizontalPadding: 4,
            verticalPadding: 4,
            onChange: (value) {
              setState(() {});
            },
            hintText: 'Add a title like, "DIY", or, "Recipes"',
            textController: _namingController,
          ),
        ],
      ),
    );
  }

//* pick one of these row
  Widget suggestsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Or pick one of these:",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggests
                  .map(
                    (elem) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: tagWidget(
                        title: elem,
                        isSelected: false,
                        onClick: () => _updateWithSuggest(suggest: elem),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

//ToDo collaborators board
  Widget collaboratorsBoard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Collaborators",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),
          usersItemBuilder()
        ],
      ),
    );
  }

//* visibility
  Widget visibilitySection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Visibility",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),
          //* switch tile
          switchTile(
            title: "Keep this board secret",
            value: _isSecret,
            onSwitch: (value) => _switchSecretState(state: value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              "If you don't want others to see this board, keep it secret",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Colors.grey.withOpacity(.9),
              ),
            ),
          )
        ],
      ),
    );
  }

  //* users items builder
  Widget usersItemBuilder() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: followItems.length,
        itemBuilder: (context, index) {
          UserModel user = followItems[index];
          return ListTile(
            leading: profileWidget(
                imageUrl: user.pfpUrl, userName: user.userName, size: 40),
            title: Text(
              user.userName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
            ),
            trailing: GestureDetector(
              onTap: () {
                selectUsers(userId: user.userId);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                decoration: BoxDecoration(
                    color: isUserSelected(userId: user.userId)
                        ? Colors.grey.withOpacity(.3)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 1.5, color: Theme.of(context).iconTheme.color!)),
                child: Text(
                  isUserSelected(userId: user.userId) ? "Remove" : "add",
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
            ),
          );
        });
  }
}
