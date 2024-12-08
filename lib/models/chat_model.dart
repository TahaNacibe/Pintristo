import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String receiverId;
  String chatId;
  String receiverName;
  String? receiverPfp;
  final String? lastMessage;
  final Timestamp? timestamp;
  String? bgUrl; // New nullable field
  List<String> blocked; // Change to a list of strings

  ChatModel({
    required this.receiverId,
    required this.receiverName,
    required this.chatId,
    this.receiverPfp,
    this.lastMessage,
    this.timestamp,
    this.bgUrl, // Include new field in constructor
    required this.blocked, // Update constructor to accept a list of strings
  });

  // Method to get the last message text or "Image"
  String getLastMessageText() {
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      // Check if the last message is an image URL
      if (lastMessage!.toLowerCase().contains('http') ||
          lastMessage!.toLowerCase().endsWith('.png') ||
          lastMessage!.toLowerCase().endsWith('.jpg')) {
        return "Image"; // Return "Image" if it's an image
      }
      return lastMessage!; // Return the last message text
    }
    return "No messages"; // Return default text if no messages
  }

  // Method to create a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      receiverId: json['receiverId'] ?? "null",
      chatId: json["chatId"] ?? "null",
      receiverName: json['receiverName'] ?? "null",
      receiverPfp: json['receiverPfp'] ?? "null",
      lastMessage: json['lastMessage'] ?? "null",
      timestamp: json['timestamp'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
      bgUrl: json['bgUrl'], // Handle bgUrl from JSON
      blocked: List<String>.from(json['blocked'] ?? []), // Update to parse a list of strings
    );
  }

  // Method to convert ChatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      "chatId": chatId,
      'receiverName': receiverName,
      'receiverPfp': receiverPfp,
      'lastMessage': lastMessage,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'bgUrl': bgUrl, // Include bgUrl in JSON output
      'blocked': blocked, // Update to include the list of strings in JSON output
    };
  }
}
