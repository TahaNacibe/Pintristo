import 'package:flutter/material.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/services/updater.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/profile_image.dart';

class AddMoreContr extends StatefulWidget {
  final List<String> followingsIds;
  final List<String> alreadySelectedIds;
  final String boardId;

  const AddMoreContr({
    required this.followingsIds,
    required this.boardId,
    required this.alreadySelectedIds,
    super.key,
  });

  @override
  State<AddMoreContr> createState() => _AddMoreContrState();
}

class _AddMoreContrState extends State<AddMoreContr> {
  final UserServices _userServices = UserServices();
  List<UserModel?> users = [];
  List<String> selectedIds = [];

  @override
  void initState() {
    super.initState();
    getFollowingUsersList();
  }

  void getFollowingUsersList() async {
    List<UserModel> fetchedUsers = [];

    for (String id in widget.followingsIds) {
      UserModel? user =
          await _userServices.getOtherUserDetails(userId: id, context: context);
      if (user != null) {
        fetchedUsers.add(user);
      }
    }

    setState(() {
      users = fetchedUsers;
      // Remove already selected users from the list
      users.removeWhere(
          (elem) => widget.alreadySelectedIds.contains(elem!.userId));
    });
  }

  bool isUserSelected(String userId) {
    return selectedIds.contains(userId);
  }

  void changeUserSelection(String userId) {
    if (isUserSelected(userId)) {
      selectedIds.remove(userId);
    } else {
      selectedIds.add(userId);
    }
    setState(() {}); // Update UI after changing selection
  }

  void changeUserSelectionDataBase(String userId) {
    if (isUserSelected(userId)) {
      Updater().updateListField(
        context: context,
        userId: widget.boardId,
        fieldName: "contributors",
        item: userId,
        collection: "boards",
        isAdd: true,
      );
    } else {
      Updater().updateListField(
        context: context,
        userId: widget.boardId,
        fieldName: "contributors",
        item: userId,
        collection: "boards",
        isAdd: false,
      );
    }
    setState(() {}); // Update UI after changing selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarCostume(),
      body: bodyWidget(),
    );
  }

  // App bar
  PreferredSizeWidget appBarCostume() {
    return PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () =>
                  Navigator.pop(context), // Close the modal on back press
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                child: glowButtons(
                  horizontalPadding: 0,
                  title: "Add",
                  buttonColor: selectedIds.isEmpty
                      ? Colors.grey.withOpacity(.7)
                      : Colors.red,
                  onClick: () {
                    if (selectedIds.isNotEmpty) {
                      for (String id in selectedIds) {
                        changeUserSelectionDataBase(id);
                      }
                      users.removeWhere(
                          (user) => !selectedIds.contains(user!.userId));
                      Navigator.pop(context,
                          users); // Close the modal and return the list of UserModels
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }

  // Body
  Widget bodyWidget() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        UserModel user = users[index]!;
        return ListTile(
          leading: profileWidget(
              imageUrl: user.pfpUrl, userName: user.userName, size: 45),
          title: Text(
            user.userName,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          trailing: GestureDetector(
            onTap: () => changeUserSelection(
                user.userId), // Toggle user selection on tap
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.grey.withOpacity(.5), width: 1.5),
              ),
              child: Text(
                isUserSelected(user.userId) ? "Remove" : "Add",
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Updated to return a list of UserModel
Future<List<UserModel>?> showMoreUsersSheet({
  required BuildContext context,
  required List<String> followingIds,
  required List<String> alreadySelectedIds,
  required String boardId,
}) async {
  return await showModalBottomSheet<List<UserModel>>(
    context: context,
    builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AddMoreContr(
          followingsIds: followingIds,
          boardId: boardId,
          alreadySelectedIds: alreadySelectedIds,
        ),
      );
    },
  );
}
