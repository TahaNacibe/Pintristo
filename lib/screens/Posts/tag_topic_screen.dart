import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/fast_snackbar.dart';
import 'package:pintresto/models/tag_model.dart';
import 'package:pintresto/screens/Posts/dialogs/confirm_dialog.dart';
import 'package:pintresto/screens/Posts/dialogs/create_tag.dart';
import 'package:pintresto/screens/Posts/widgets/search_filed.dart';
import 'package:pintresto/screens/Posts/widgets/tag_widget.dart';
import 'package:pintresto/services/search_services.dart';
import 'package:pintresto/utils/models_utils.dart';
import 'package:pintresto/utils/text_utils.dart';
import 'package:pintresto/widgets/glow_buttons.dart';
import 'package:pintresto/widgets/loading_widget.dart';

class TagTopicScreen extends StatefulWidget {
  final List<TagModel> initialTags;
  const TagTopicScreen({required this.initialTags, super.key});

  @override
  State<TagTopicScreen> createState() => _TagTopicScreenState();
}

class _TagTopicScreenState extends State<TagTopicScreen> {
  //* vars
  final List<TagModel> _selectedTags = [];
  List<TagModel> _searchResultTags = [];
  bool _isSearching = false;

  //* instances initializing
  final SearchServices _searchServices = SearchServices();
  //* controllers
  final TextEditingController _tagsController = TextEditingController();

  //* functions declaration
  bool isTagsEmpty() {
    return _selectedTags.isEmpty;
  }

  // check controller if empty
  bool isControllerHoldText() {
    return _tagsController.text.isNotEmpty;
  }

  // clear controller
  void clearController() {
    setState(() {
      _searchResultTags.clear();
      _tagsController.clear();
    });
  }

  // is item selected
  bool isTagSelected({required TagModel tag}) {
    List<String> selectedTagsNames =
        _selectedTags.map((tag) => tag.name).toList();
    return selectedTagsNames.contains(tag.name);
  }

  // is item selected
  bool isTagInSearch({required TagModel tag}) {
    List<String> selectedTagsNames =
        _searchResultTags.map((tag) => tag.name).toList();
    return selectedTagsNames.contains(tag.name);
  }

  //switch select state
  void switchTagSelectState({required TagModel tag, required isSelected}) {
    setState(() {
      if (_selectedTags.length < 10) {
        //* update lists
        updateTagsLists(isSelected: isSelected, tag: tag);
        clearController();
      } else {
        //* show warning message
        showFastSnackbar(context, "Can't have more then 10 tags");
      }
    });
  }

  // update list tags
  void updateTagsLists({required TagModel tag, required isSelected}) {
    if (isSelected) {
      //* adding item to selected and removing it from search result
      _selectedTags.remove(tag);
      _searchResultTags.add(tag);
    } else {
      //* removing item from selected and adding it to search result
      _searchResultTags.remove(tag);
      _selectedTags.add(tag);
    }
  }

  bool isTheItemSearchedSelected() {
    return !_selectedTags.any((elem) => _tagsController.text == elem.name);
  }

  // update search
  void updateOnSearch({required String searchTerm}) {
    //* set to search widget
    setState(() {
      _isSearching = true;
    });
    if (_tagsController.text.isEmpty) {
      _searchResultTags.clear();
    }
    //* grab data
    _searchServices
        .searchTags(searchTerm.toLowerCase().trim(), context)
        .then((result) {
      setState(() {
        //* return to display widget
        _searchResultTags =
            result.where((elem) => !_selectedTags.contains(elem)).toList();
        _isSearching = false;
        for (TagModel tag in result) {
          //* check if the tag do exist in any of the list then don't grab it again
          if (!isTagSelected(tag: tag) && !isTagInSearch(tag: tag)) {
            //* else add it to list
            _searchResultTags.add(tag);
          }
        }
      });
    });
  }

  //* handle sudden exit
  Future<void> onExit() async {
    if (isTheListsEqual(
        firstList: widget.initialTags, secondList: _selectedTags)) {
      Navigator.of(context).pop(<TagModel>[]);
    } else {
      inCaseChangeAccrues();
    }
  }

  // in case change happened
  Future<void> inCaseChangeAccrues() async {
    bool answer = await showConfirmBottomSheet(context,"Do you want to save your changes before leaving this page?","Save changes");
    if (answer) {
      Navigator.of(context).pop(_selectedTags);
    } else {
      Navigator.of(context).pop(widget.initialTags);
    }
  }

  //* init state
  @override
  void initState() {
    _selectedTags.addAll(widget.initialTags);
    super.initState();
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        onExit();
      },
      child: Scaffold(
        body: tagTopicScreenBody(),
      ),
    );
  }

  //* widget body tree
  Widget tagTopicScreenBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* costume app bar
          tagsScreenAppBar(),
          //* search filed
          searchFiled(
              hintText: "Search topic",
              textController: _tagsController,
              onWrite: () {
                updateOnSearch(searchTerm: _tagsController.text);
              },
              isEditing: isControllerHoldText(),
              trailing: (_tagsController.text.isNotEmpty &&
                      _searchResultTags.isEmpty &&
                      isTheItemSearchedSelected() &&
                      !_isSearching)
                  ? IconButton(
                      onPressed: () {
                        showCreateTagBottomSheet(context, _tagsController.text,
                            () {
                          _searchServices
                              .createCostumeTag(
                                  tag: _tagsController.text, context: context)
                              .then((value) {
                            if (value != null) {
                              Navigator.pop(context);
                              setState(() {
                                _selectedTags.add(value);
                              });
                            }
                          });
                        });
                      },
                      icon: Icon(Icons.add))
                  : IconButton(
                      onPressed: () {
                        clearController();
                      },
                      icon: const Icon(Icons.close_rounded))),
          //* selected section title
          titleForSections(
              text: "Selected:", showWidget: _selectedTags.isNotEmpty),
          //* selected items
          selectedItemsWidget(),
          //* selected section title
          titleForSections(
              text: "Tags to use:",
              showWidget: _searchResultTags.isNotEmpty && !_isSearching),
          //* search items
          tagsSearchWidget(tags: _searchResultTags)
        ],
      ),
    );
  }

  //* tags screen costume app bar
  Widget tagsScreenAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // go back button
        IconButton(
            onPressed: () async {
              onExit();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        //title
        const Text(
          "Tag topics",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        // done button
        SizedBox(
            width: 90,
            child: glowButtons(
                horizontalPadding: 0,
                title: 'Done',
                buttonColor: !isTagsEmpty() ? Colors.red : Colors.grey,
                onClick: () {
                  //* send the tags back to the post screen
                  Navigator.of(context).pop(_selectedTags);
                }))
      ],
    );
  }

  //* selected items builder
  Widget selectedItemsWidget() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
          itemCount: _selectedTags.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            //* vars
            TagModel tag = _selectedTags[index];
            //* Ui tree
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: tagWidget(
                  title: capitalizeFirstLetter(tag.name),
                  isSelected: true,
                  onClick: () =>
                      switchTagSelectState(tag: tag, isSelected: true)),
            );
          }),
    );
  }

  //* items widget
  Widget tagsSearchWidget({required List<TagModel> tags}) {
    return Expanded(
      child: _isSearching
          ? loadingWidget()
          : GridView.builder(
              itemCount: tags.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5),
              itemBuilder: (context, index) {
                //* var
                TagModel tagItem = tags[index];
                //* Ui tree
                return tagWidget(
                    title: capitalizeFirstLetter(tagItem.name),
                    isSelected: false,
                    onClick: () =>
                        switchTagSelectState(tag: tagItem, isSelected: false));
              }),
    );
  }

  //* sections names
  Widget titleForSections({required String text, required bool showWidget}) {
    return showWidget
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          )
        : const SizedBox.shrink();
  }
}
