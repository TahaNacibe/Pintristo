import 'package:flutter/material.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/keys/prefernces_keys.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/screens/Posts/new_post.dart';
import 'package:pintresto/screens/Settings/dialogs/grid_dialog.dart';
import 'package:pintresto/screens/Settings/widgets/board_item.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/shared_prefernces.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class BoardsPage extends StatefulWidget {
  const BoardsPage({super.key});

  @override
  State<BoardsPage> createState() => _BoardsPageState();
}

class _BoardsPageState extends State<BoardsPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  bool isGroup = false;
  int gridCount = 2;
  List<BoardModel> userBoards = [];
  List<BoardModel> userSearchResultBoards = [];
  InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none);

//* instances
  final BoardServices _boardServices = BoardServices();
  final AuthServices _authServices = AuthServices();
  final SharedPreferencesHelper _sharedPreferencesHelper =
      SharedPreferencesHelper();

  //* functions
  List<BoardModel> getSarahResult({required String searchTerm}) {
    return userBoards
        .where((board) => board.name.toLowerCase().contains(searchTerm))
        .toList();
  }

  List<BoardModel> getGroupsBoards() {
    return userBoards.where((board) => board.contributors.length > 1).toList();
  }

  void updateBoardGridPreferences(int result) {
    _sharedPreferencesHelper.saveInt(boardKey, result);
  }

  @override
  void initState() {
    _boardServices
        .userBoards(
            context: context,
            userId: _authServices.getTheCurrentUserId(),
            isUser: true)
        .then((result) {
      setState(() {
        userBoards = result;
        isLoading = false;
      });
    });
    _sharedPreferencesHelper.getInt(boardKey).then((value) {
      setState(() {
        gridCount = value ?? 2;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(),
      body: !isLoading ? itemBuilder() : loadingWidget(),
    );
  }

  //* search bar
  PreferredSizeWidget searchAppBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          //* search functions
                          if (value.isNotEmpty) {
                            isSearching = true;
                          } else {
                            isSearching = false;
                          }
                          setState(() {});
                        },
                        onTap: () {},
                        onSubmitted: (value) {},
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 8),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  if (isSearching) {
                                    setState(() {
                                      isSearching = false;
                                      searchController.clear();
                                    });
                                  } else {
                                    showPostBottomSheet(context);
                                  }
                                },
                                icon: Icon(
                                    isSearching ? Icons.close : Icons.add)),
                            prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search)),
                            hintText: "Search your Pins",
                            filled: true,
                            fillColor: Colors.grey.withOpacity(.2),
                            border: border),
                      ),
                    ),
                  ],
                ),
                filterBar(),
              ],
            )));
  }

  //* filter buttons
  Widget filterButtons(
      {required Widget child,
      required bool? relatedBool,
      required VoidCallback onPress}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).iconTheme.color!,
                  width: (relatedBool != null && relatedBool) ? 1.5 : .8)),
          child: child,
        ),
      ),
    );
  }

  //* filter bar
  Widget filterBar() {
    return Row(
      children: [
        filterButtons(
            child: const Icon(Icons.sort_rounded),
            relatedBool: null,
            onPress: () async {
              //* change grid
              int? result = await showGridBottomSheet(context, gridCount);
              setState(() {
                if (result != null) {
                  gridCount = result;
                  updateBoardGridPreferences(result);
                }
              });
            }),
        filterButtons(
            child: const Text(
              "Group",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            relatedBool: isGroup,
            onPress: () {
              //* change the related bool state
              setState(() {
                isGroup = !isGroup;
              });
            }),
      ],
    );
  }

  void updateData() {
    setState(() {
      isLoading = true;
    });
    _boardServices
        .userBoards(
            context: context,
            userId: _authServices.getTheCurrentUserId(),
            isUser: true)
        .then((result) {
      setState(() {
        userBoards = result;
        isLoading = false;
      });
    });
  }

  Widget itemBuilder() {
    userSearchResultBoards = isSearching
        ? getSarahResult(searchTerm: searchController.text.toLowerCase())
        : isGroup
            ? getGroupsBoards()
            : userBoards;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: userSearchResultBoards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5, crossAxisCount: gridCount),
          itemBuilder: (context, index) {
            return BoardItem(
              board: userSearchResultBoards[index],
              onBoardDelete: () {
                updateData();
              },
              onDeleteEffect: (selectedIds) {
                updateData();
              },
            );
          }),
    );
  }
}
