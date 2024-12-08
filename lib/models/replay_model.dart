import 'package:cloud_firestore/cloud_firestore.dart';

class ReplayModel {
  String commentId;
  Timestamp timeStamp;
  String ownerId;
  List<String> reactionsCount; // Changed to List<String>
  bool isImage; // New field
  String? imageUrl; // New field with default null

  ReplayModel({
    required this.commentId,
    required this.timeStamp,
    required this.ownerId,
    required this.reactionsCount, // Updated constructor
    required this.isImage, // Updated constructor
    this.imageUrl, // Updated constructor
  });

  // Convert a CommentModel into a Map.
  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'timeStamp': timeStamp,
      'ownerId': ownerId,
      'reactionsCount': reactionsCount, // Updated to JSON
      'isImage': isImage, // Added to JSON
      'imageUrl': imageUrl, // Added to JSON
    };
  }

  // Convert a Map into a CommentModel.
  factory ReplayModel.fromJson(Map<String, dynamic> json) {
    return ReplayModel(
      commentId: json['commentId'],
      timeStamp: json['timeStamp'],
      ownerId: json['ownerId'],
      reactionsCount: List<String>.from(json['reactionsCount']), // Updated from JSON
      isImage: json['isImage'], // Added from JSON
      imageUrl: json['imageUrl'], // Added from JSON
    );
  }
}
