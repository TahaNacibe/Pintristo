import 'package:flutter/material.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Search/widget/idea_holder.dart';
import 'package:pintresto/screens/Settings/profile_page.dart';
import 'package:pintresto/services/search_services.dart';
import 'package:pintresto/utils/text_utils.dart';
import 'package:pintresto/widgets/error_future.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/pin_item.dart';
import 'package:pintresto/widgets/profile_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool search = false;
  bool isSearchResult = false;
  bool isLoading = true;
  String searchWord = "";
  Map<String, dynamic> popularIdeas = {};
  //* controllers
  TextEditingController searchController = TextEditingController();
  //* instances
  final SearchServices _searchServices = SearchServices();
  //* display
  InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none);
  @override
  void initState() {
    _searchServices.getTopSearchTerms(context).then((result) {
      setState(() {
        popularIdeas = result;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: searchAppBar(),
        body: isSearchResult
            ? _postsTab()
            : (!search
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: const Text(
                          "Popular on Pintresto",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 18),
                        ),
                      ),
                      ideasWidgetDisplay(),
                    ],
                  )
                : searchDialog()),
      ),
    );
  }

  //* app bar
  PreferredSizeWidget searchAppBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    readOnly: isSearchResult,
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    onTap: () {
                      setState(() {
                        isSearchResult = false;
                        search = true;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchWord = value;
                        isSearchResult = true;
                        search = true;
                        _searchServices.updateSearchCounter(
                            context: context, searchTerm: searchWord);
                      });
                    },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 8),
                        suffixIcon: IconButton(
                            onPressed: () {
                              if (searchController.text.isNotEmpty) {
                                setState(() {
                                  searchController.clear();
                                  isSearchResult = false;
                                  search = false;
                                });
                              }
                            },
                            icon: Icon(searchController.text.isEmpty
                                ? Icons.camera
                                : Icons.close)),
                        prefixIcon: IconButton(
                            onPressed: () {}, icon: const Icon(Icons.search)),
                        hintText: "Search",
                        filled: true,
                        fillColor: Colors.grey.withOpacity(.2),
                        border: border),
                  ),
                ),
                if (search)
                  TextButton(
                      onPressed: () {
                        setState(() {
                          search = false;
                          isSearchResult = false;
                          searchController.clear();
                        });
                      },
                      child: Text(
                        "Cancel",
                        style:
                            TextStyle(color: Theme.of(context).iconTheme.color),
                      ))
              ],
            )));
  }

  //* ideas holder final widget
  Widget ideasWidgetDisplay() {
    return isLoading
        ? SizedBox(height: 300, child: loadingWidget())
        : ideasHolder();
  }

  //* search result
  Widget _postsTab() {
    return FutureBuilder<List<PostModel>>(
      future: _searchServices.getPostsByPartialNameOrTags(
          searchName: searchWord, context: context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return errorWidget(text: "No posts available");
        } else {
          List<PostModel> posts = snapshot.data!;
          return customTwoColumnBuilder(posts: posts);
        }
      },
    );
  }

//* search dialog
  Widget searchDialog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(
            future: _searchServices.searchPeopleByName(
                context: context, searchName: searchController.text),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget();
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return errorWidget(text: "No posts available");
              } else {
                List<UserModel> usersList = snapshot.data!["users"];
                List<String> searchTerms = snapshot.data!["matchedSearchTerms"];
                return Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: usersList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                              isCurrentUser: false,
                                              userId: usersList[index].userId,
                                            )));
                              },
                              child: peopleDisplay(user: usersList[index]));
                        }),
                    //* terms
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchTerms.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchWord = searchTerms[index];
                                  searchController.text = searchWord;
                                  isSearchResult = true;
                                  _searchServices.updateSearchCounter(
                                      context: context, searchTerm: searchWord);
                                });
                              },
                              child: searchTermDisplay(
                                  result: searchTerms[index]));
                        }),
                  ],
                );
              }
            })
      ],
    );
  }

  //* people display widget
  Widget peopleDisplay({required UserModel user}) {
    return ListTile(
      leading: profileWidget(
          imageUrl: user.pfpUrl, userName: user.userName, size: 50),
      title: Row(
        children: [
          Text(
            user.userName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            width: 8,
          ),
          if (user.isVerified)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.red),
              child: Icon(
                Icons.done,
                color: Theme.of(context).scaffoldBackgroundColor,
                size: 15,
              ),
            )
        ],
      ),
      subtitle: Text(
        user.userName.toLowerCase().replaceAll(" ", ""),
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  //* search term display
  Widget searchTermDisplay({required String result}) {
    result = result.replaceAll(searchController.text, "");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 35,
          ),
          const SizedBox(
            width: 14,
          ),
          Text.rich(
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              TextSpan(children: [
                TextSpan(
                    text: searchController.text,
                    style: TextStyle(color: Colors.grey.withOpacity(.7))),
                TextSpan(text: result),
              ])),
        ],
      ),
    );
  }

  //* ideas holder
  Widget ideasHolder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: popularIdeas.keys.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              crossAxisCount: 2),
          itemBuilder: (context, index) {
            String tagName = popularIdeas.keys.toList()[index];
            return Padding(
              padding: const EdgeInsets.all(4),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      searchWord = tagName;
                      searchController.text = tagName;
                      isSearchResult = true;
                      search = true;
                    });
                  },
                  child: ideaHolderItem(
                      tag: capitalizeFirstLetter(tagName),
                      imageUrl: popularIdeas[tagName])

                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(15),
                  //       color: Colors.grey.withOpacity(.5)),
                  //   child: Center(
                  //     child: Text(
                  //       popularIdeas.keys.toList()[index],
                  //       textAlign: TextAlign.center,
                  //       style: const TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 20,
                  //           color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  ),
            );
          }),
    );
  }
}
