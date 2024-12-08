import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pintresto/auth/auths_services.dart';
import 'package:pintresto/models/board_model.dart';
import 'package:pintresto/models/post_model.dart'; // Updated PostModel
import 'package:pintresto/models/user_model.dart';
import 'package:pintresto/screens/Settings/pages/board_details.dart';
import 'package:pintresto/services/board_services.dart';
import 'package:pintresto/services/posts_services.dart';
import 'package:pintresto/services/user_services.dart';
import 'package:pintresto/widgets/error_future.dart';
import 'package:pintresto/widgets/loading_widget.dart';
import 'package:pintresto/widgets/pin_item.dart'; // Assuming you have this widget

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage>
    with SingleTickerProviderStateMixin {
  //* vars
  List<BoardModel> userBoards = [
    BoardModel(
        name: "All",
        boardId: "",
        isSecret: false,
        postsIds: [],
        cover: "",
        contributors: [])
  ];
  TabController? _tabController;
  bool isLoading = true;

  //* pagination vars
  bool _hasMorePosts = true;
  bool _isLoadingPosts = false;
  DocumentSnapshot? _lastDocument;
  final int _limit = 20;

  //* Loaded posts
  final List<PostModel> _loadedPosts = [];

  //* instances
  final AuthServices _authServices = AuthServices();
  final BoardServices _boardServices = BoardServices();
  final UserServices _userServices = UserServices();
  //* instances
  final PostsServices _postsServices =
      PostsServices(userServices: UserServices());

  //* functions
  Future<List<PostModel>> fetchPostsList({required List<String> ids}) async {
    // Fetch posts concurrently using Future.wait
    List<PostModel?> fetchedPosts = await Future.wait(ids.map((id) {
      return _postsServices.getPostById(postId: id, context: context);
    }));

    // Filter out any null posts
    List<PostModel> nonNullPosts = fetchedPosts.whereType<PostModel>().toList();

    return nonNullPosts;
  }

  Future<List<PostModel>> _fetchPosts({DocumentSnapshot? startAfter}) async {
    Query query = FirebaseFirestore.instance
        .collection("Pins")
        .limit(_limit)
        .orderBy("timestamp", descending: false);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final querySnapshot = await query.get();
    _hasMorePosts = querySnapshot.docs.length == _limit;
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    List<PostModel> posts = querySnapshot.docs
        .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Fetch and append post owner details
    for (PostModel post in posts) {
      UserModel? postOwner =
          await _userServices.getPostOwner(id: post.ownerId, context: context);
      if (postOwner != null) {
        post.ownerPfp = postOwner.pfpUrl;
        post.ownerName = postOwner.userName;
        post.followers = postOwner.followersIds.length;
      } else {
        post.ownerPfp = "pass";
        post.ownerName = "pass";
      }
    }

    return posts;
  }

  void updateUserBoardsList() async {
    List<BoardModel> boardsList = await _boardServices.userBoards(
        context: context,
        userId: _authServices.getTheCurrentUserId(),
        isUser: true);
    if (mounted) {
      setState(() {
        userBoards = [
          BoardModel(
              name: "All",
              boardId: "",
              isSecret: false,
              contributors: [],
              postsIds: [],
              cover: ""),
          ...boardsList
        ];
        _tabController?.dispose();
        _tabController = TabController(
          length: userBoards.length,
          vsync: this,
        );
        isLoading = false;
      });
    }
  }

  Future<void> boardListUpdateOnRefresh() async {
    List<BoardModel> boardsList = await _boardServices.userBoards(
        context: context,
        userId: _authServices.getTheCurrentUserId(),
        isUser: true);
    if (mounted) {
      setState(() {
        userBoards = [
          BoardModel(
              name: "All",
              boardId: "",
              isSecret: false,
              contributors: [],
              postsIds: [],
              cover: ""),
          ...boardsList
        ];
        // _tabController?.dispose();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateUserBoardsList();
    _loadMorePosts(); // Load initial posts
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: forYouAppBar(),
      body: isLoading
          ? Center(child: loadingWidget())
          : TabBarView(
              controller: _tabController,
              children: [
                _postsTab(null, _loadedPosts), // Display posts in the "All" tab
                ...userBoards
                    .skip(1)
                    .map((board) => pagesFotOtherBoards(board: board)),
              ],
            ),
    );
  }

  //* app bar for the for you page
  PreferredSizeWidget forYouAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: _tabController == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 4.0,
                      color: Theme.of(context).iconTheme.color!,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: 0.0),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  tabs: userBoards.map((board) {
                    return Tab(
                      child: Text(
                        board.name,
                        style: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _postsTab(ScrollPhysics? scroll, List<PostModel> loadedPosts) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!_isLoadingPosts &&
            _hasMorePosts &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMorePosts(); // Load more posts if reached the bottom
        }

        return true;
      },
      child: loadedPosts.isEmpty
          ? loadingWidget() // Show loading until posts are fetched initially
          : RefreshIndicator(
              onRefresh: () async {
                boardListUpdateOnRefresh();
                _loadMorePosts(); // Load initial posts
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    customTwoColumnBuilder(
                        posts: loadedPosts,
                        onRefresh: (postId) {
                          setState(() {
                            _loadedPosts
                                .removeWhere((elem) => elem.postId == postId);
                          });
                        }),
                    if (_isLoadingPosts)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child:
                            loadingWidget(), // Show loading at the bottom when fetching more
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingPosts) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoadingPosts = true;
    });

    List<PostModel> morePosts = await _fetchPosts(startAfter: _lastDocument);

    if (morePosts.isNotEmpty) {
      setState(() {
        _loadedPosts.addAll(morePosts); // Append new posts to the existing list
      });
    }

    setState(() {
      _isLoadingPosts = false;
    });
  }

  //* board tile widget
  Widget boardTile({required BoardModel board}) {
    return board.postsIds.isEmpty
        ? const SizedBox.shrink()
        : boardTileDisplayItem(board: board);
  }

  //* board tile display item
  Widget boardTileDisplayItem({required BoardModel board}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image(
            image: NetworkImage(board.cover),
            fit: BoxFit.cover,
            width: 60,
            height: 60,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                board.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              Text(
                "${board.postsIds.length} Pin",
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              )
            ],
          ),
        )
      ],
    );
  }

  //* pages
  Widget pagesFotOtherBoards({required BoardModel board}) {
    return RefreshIndicator(
      onRefresh: () async {
        boardListUpdateOnRefresh();
        _loadMorePosts(); // Load initial posts
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 14),
              child: GestureDetector(
                  onTap: () {
                    fetchPostsList(ids: board.postsIds).then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BoardDetails(
                                  board: board,
                                  boardPosts: value,
                                  delete: (_) {},
                                  onBoardDelete: () {})));
                    });
                  },
                  child: boardTile(board: board)),
            ),
            FutureBuilder(
                future: _postsServices.getPostsForBoardType(
                    board: board, context: context),
                builder: (context, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return loadingWidget();
                  } else if (snapShot.connectionState == ConnectionState.none) {
                    return errorWidget(text: "Something went wrong");
                  } else {
                    if (snapShot.data!.isEmpty) {
                      return errorWidget(text: "No Pins share the same tags");
                    } else {
                      return _postsTab(
                          const NeverScrollableScrollPhysics(), snapShot.data!);
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
