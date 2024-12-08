import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String senderId;
  String message;
  String? senderName;
  bool isDeleted;
  String? senderPfp;
  List<String?>? imageUrl; // Add imageUrl to handle image messages
  Timestamp timestamp;
  String? messageId; // Add messageId to handle optional message ID

  MessageModel({
    required this.senderId,
    required this.message,
    this.imageUrl,
    this.senderName,
    this.senderPfp,
    this.isDeleted = false,
    required this.timestamp,
    this.messageId, // Accept messageId as an optional parameter
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      senderName: json["senderName"] ?? "user",
      senderPfp: json["senderPfp"] ?? "pfp",
      message: json['message'],
      isDeleted: json["isDeleted"] ?? false,
      imageUrl: json['imageUrl'] != null
          ? List<String>.from(json['imageUrl'].map((img) => img))
          : [], // Handle imageUrl
      timestamp: json['timestamp'],
      messageId: json['messageId'], // Handle messageId, can be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      "senderName": senderName,
      'senderPfp': senderPfp,
      "isDeleted": isDeleted,
      'message': message,
      'imageUrl': imageUrl, // Include imageUrl in toJson
      'timestamp': timestamp,
      'messageId': messageId, // Include messageId in toJson
    };
  }
}
