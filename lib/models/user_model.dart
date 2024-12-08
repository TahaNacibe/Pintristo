import 'package:pintresto/models/notification_model.dart';

class UserModel {
  String userName;
  String pfpUrl;
  String email;
  String userId;
  String? userCover;
  List<String> followersIds;
  List<String> favorites;
  List<String> followingIds;
  List<String> likedPosts;
  List<String> yourBoards;
  List<String> savedPins;
  List<String> userPins; // {{ edit_1: Added userPins list }}
  List<String> drafts; // {{ edit_2: Renamed draft to drafts }}
  bool isVerified =
      false; // {{ edit_3: Added isVerified with default value false }}
  List<NotificationModel>
      notifications; // {{ edit_1: Changed list name and type }}
  List<String> chatsIds; // {{ edit_1: Added chatsIds list }}
  bool isVisible =
      true; // {{ edit_1: Added isVisible with default value true }}

  UserModel({
    required this.userName,
    required this.pfpUrl,
    required this.likedPosts,
    required this.userId,
    this.userCover,
    required this.email,
    required this.followersIds,
    required this.followingIds,
    required this.yourBoards,
    required this.favorites,
    required this.savedPins,
    required this.userPins, // {{ edit_4: Added userPins to constructor }}
    required this.drafts, // {{ edit_5: Renamed draft to drafts in constructor }}
    this.isVerified = false, // {{ edit_6: Added isVerified to constructor }}
    required this.notifications, // {{ edit_2: Updated constructor for notifications }}
    required this.chatsIds, // {{ edit_2: Added chatsIds to constructor }}
    this.isVisible = true, // {{ edit_2: Added isVisible to constructor }}
  });

  // Convert a UserModel instance to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'pfpUrl': pfpUrl,
      'likedPosts': likedPosts,
      'userId': userId,
      'favorites': favorites,
      'followersIds': followersIds,
      'followingIds': followingIds,
      "isVisible": isVisible,
      'yourBoards': yourBoards,
      'userCover': userCover,
      'savedPins': savedPins,
      'userPins': userPins, // {{ edit_7: Added userPins to JSON conversion }}
      'drafts':
          drafts, // {{ edit_8: Renamed draft to drafts in JSON conversion }}
      'isVerified':
          isVerified, // {{ edit_9: Added isVerified to JSON conversion }}
      'notifications': notifications
          .map((n) => n.toMap())
          .toList(), // {{ edit_3: Updated JSON conversion for notifications }}
      'chatsIds': chatsIds, // {{ edit_3: Added chatsIds to JSON conversion }}
    };
  }

  // Create a UserModel instance from a Map (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print(json['yourBoards']);
    return UserModel(
      userName: json['userName'],
      pfpUrl: json['pfpUrl'],
      userCover: json['userCover'],
      email: json["email"],
      userId: json['userId'],
      likedPosts: List<String>.from(json['likedPosts']),
      favorites: List<String>.from(json['favorites']),
      followersIds: List<String>.from(json['followersIds']),
      followingIds: List<String>.from(json['followingIds']),
      yourBoards: List<String>.from(json['yourBoards']),
      savedPins: List<String>.from(json['savedPins']),
      userPins: List<String>.from(
          json['userPins']), // {{ edit_10: Added userPins from JSON }}
      drafts: json['drafts'] != null
          ? List<String>.from(json['drafts'])
          : <String>[], // {{ edit_11: Renamed draft to drafts from JSON }}
      isVerified: json['isVerified'] ??
          false, // {{ edit_12: Added isVerified from JSON }}
      notifications: json['notifications'] != null
          ? List<NotificationModel>.from(
              json['notifications'].map((n) => NotificationModel.fromMap(n)))
          : [], // {{ edit_4: Updated fromJson for notifications }}
      chatsIds: List<String>.from(
          json['chatsIds'] ?? []), // {{ edit_4: Added chatsIds from JSON }}
      isVisible: json['isVisible'] ??
          true, // {{ edit_3: Added isVisible from JSON with default true }}
    );
  }
}
