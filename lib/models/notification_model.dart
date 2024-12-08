import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id; // {{ edit_1 }}
  String title;
  String pfpUrl;
  String name;
  String actionType;
  Timestamp timestamp;
  String? desc;
  bool isSeen; // {{ edit_2 }}
  String destinationId; // {{ edit_10 }}
  bool isNotificationSent; // {{ edit_14 }}

  // Constructor to initialize the fields
  NotificationModel({
    required this.id, // {{ edit_3 }}
    required this.title,
    required this.pfpUrl,
    required this.name,
    required this.actionType,
    required this.timestamp,
    this.desc,
    this.isSeen = false, // {{ edit_4 }}
    required this.destinationId, // {{ edit_11 }}
    this.isNotificationSent = false, // {{ edit_15 }}
  });

  // Method to convert the model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // {{ edit_5 }}
      'title': title,
      'pfpUrl': pfpUrl,
      'name': name,
      'timestamp': timestamp,
      'actionType': actionType,
      'desc': desc,
      'isSeen': isSeen, // {{ edit_6 }}
      'destinationId': destinationId, // {{ edit_12 }}
      'isNotificationSent': isNotificationSent, // {{ edit_16 }}
    };
  }

  // Method to create a NotificationModel from a map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? "id", // {{ edit_7 }}
      title: map['title'] ?? "title",
      pfpUrl: map['pfpUrl'] ?? "pfp",
      timestamp: map["timestamp"] ?? Timestamp.now(),
      name: map['name'] ?? "name",
      actionType: map['actionType'] ?? "action",
      desc: map['desc'] ?? "desc", // {{ edit_8 }}
      isSeen: map['isSeen'] ?? false, // {{ edit_9 }}
      destinationId: map['destinationId'] ?? "destId", // {{ edit_13 }}
      isNotificationSent: map['isNotificationSent'] ?? false, // {{ edit_17 }}
    );
  }
}
