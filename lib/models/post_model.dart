import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String title;
  String description;
  String link;
  int followers;
  int likes;
  String? boardId;
  String ownerId;
  String postId; // {{ edit_1 }}
  String imageUrl; // {{ edit_2 }}
  String ownerPfp;
  String ownerName;
  List<String> selectedTags;
  List<String> hashtagsId;
  bool allowComments;
  String altText;
  bool showSimilarProducts;
  List<String> tagsPeopleIds;
  Timestamp timestamp; // {{ edit_9 }} // New timestamp field

  // Constructor
  PostModel({
    required this.title,
    required this.description,
    required this.link,
    this.boardId,
    this.followers = 0,
    this.likes = 0,
    this.ownerName = "",
    this.ownerPfp = "",
    required this.ownerId,
    required this.postId, // {{ edit_3 }}
    required this.imageUrl, // {{ edit_4 }}
    required this.selectedTags,
    required this.allowComments,
    required this.altText,
    required this.showSimilarProducts,
    required this.tagsPeopleIds,
    required this.hashtagsId,
    required this.timestamp, // {{ edit_10 }} // New timestamp parameter
  });

  // Factory method to create a PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      title: json['title'],
      description: json['description'],
      link: json['link'],
      followers: json["followers"] ?? 0,
      likes:  json["likes"] ?? 0,
      boardId: json['boardId'],
      ownerName: json['ownerName'] ?? "",
      ownerPfp: json['ownerPfp'] ?? "",
      ownerId: json['ownerId'],
      postId: json['postId'], // {{ edit_5 }}
      imageUrl: json['imageUrl'], // {{ edit_6 }}
      selectedTags: List<String>.from(json['selectedTags']),
      allowComments: json['allowComments'],
      altText: json['altText'],
      showSimilarProducts: json['showSimilarProducts'],
      tagsPeopleIds: List<String>.from(json['tagsPeopleIds']),
      hashtagsId: List<String>.from(json['hashtagsId']),
      timestamp: json['timestamp'], // {{ edit_11 }} // Parse timestamp from JSON
    );
  }

  // Method to convert PostModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      "followers": followers,
      'description': description,
      'link': link,
      "likes":likes,
      "ownerName": ownerName,
      "ownerPfp": ownerPfp,
      'boardId': boardId,
      'ownerId': ownerId,
      'postId': postId, // {{ edit_7 }}
      'imageUrl': imageUrl, // {{ edit_8 }}
      'selectedTags': selectedTags,
      'allowComments': allowComments,
      'altText': altText,
      'showSimilarProducts': showSimilarProducts,
      'tagsPeopleIds': tagsPeopleIds,
      'hashtagsId': hashtagsId,
      'timestamp': timestamp, // {{ edit_12 }} // Convert timestamp to JSON
    };
  }
}
