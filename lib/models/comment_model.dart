import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String commentId;
  Timestamp timeStamp;
  String ownerId;
  List<String> reactionsCount; // Changed to List<String>
  List<CommentModel> replays;
  bool isImage; // New field added
  String? imageUrl; // New field added, nullable with default null
  int replaysCount; // New field added with default value
  String? ownerName; // Optional field for owner's name
  String? ownerPfp;  // Optional field for owner's profile picture
  String? content; // New nullable field added
  bool isReplay; // New field added
  String parentCommentId; // New field added with default value

  CommentModel({
    required this.commentId,
    required this.timeStamp,
    required this.ownerId,
    required this.reactionsCount, // Updated constructor
    required this.replays,
    required this.isImage, // Updated constructor
    this.imageUrl, // Updated constructor
    this.replaysCount = 0, // Updated constructor with default value
    this.ownerName, // Updated constructor
    this.ownerPfp,  // Updated constructor
    this.content, // Updated constructor
    this.isReplay = false, // Updated constructor with default value
    this.parentCommentId = "", // Updated constructor with default value
  });

  // Convert a CommentModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'timeStamp': timeStamp,
      'ownerId': ownerId,
      'reactionsCount': reactionsCount, // Updated to JSON conversion
      'replays': replays.map((replay) => replay.toJson()).toList(),
      'isImage': isImage, // Added to JSON conversion
      'imageUrl': imageUrl, // Added to JSON conversion
      'replaysCount': replaysCount, // Added to JSON conversion
      'ownerName': ownerName, // Added to JSON conversion
      'ownerPfp': ownerPfp, // Added to JSON conversion
      'content': content, // Added to JSON conversion
      'isReplay': isReplay, // Added to JSON conversion
      'parentCommentId': parentCommentId, // Added to JSON conversion
    };
  }

  // Convert a Map into a CommentModel.
  factory CommentModel.fromJson(Map<String, dynamic> json,{String? ownerName, String? ownerPfp}) {
    return CommentModel(
      commentId: json['commentId'],
      timeStamp: json['timeStamp'],
      ownerId: json['ownerId'],
      reactionsCount: List<String>.from(json['reactionsCount'] ?? []), // Updated to JSON parsing
      replays: (json['replays'] as List)
          .map((replay) => CommentModel.fromJson(replay))
          .toList(),
      isImage: json['isImage'], // Added to JSON parsing
      imageUrl: json['imageUrl'], // Added to JSON parsing
      replaysCount: json['replaysCount'] ?? 0, // Added to JSON parsing with default
      ownerName: ownerName ?? json['ownerName'],
      ownerPfp: ownerPfp ?? json['ownerPfp'],
      content: json['content'], // Added to JSON parsing
      isReplay: json['isReplay'] ?? false, // Added to JSON parsing with default
      parentCommentId: json['parentCommentId'] ?? "", // Added to JSON parsing with default
    );
  }
}
