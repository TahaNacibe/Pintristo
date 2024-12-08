import 'package:cloud_firestore/cloud_firestore.dart';

String timeSince(Timestamp timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp.toDate());

  if (difference.inDays >= 30) {
    return '${timestamp.toDate().month.toString().padLeft(2, '0')}/${timestamp.toDate().year.toString().substring(2)}';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} m';
  } else {
    return 'Just now';
  }
}
