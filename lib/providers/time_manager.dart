import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you import the correct package for Timestamp

String ageFromTimestamp(Timestamp? timestamp) {
  if (timestamp != null) {
    final DateTime now = DateTime.now();
    final DateTime date = timestamp.toDate();
    final Duration difference = now.difference(date);

    // Calculate the number of years, months, weeks, and days
    int years = now.year - date.year;
    int months = now.month - date.month;
    int weeks = difference.inDays ~/ 7; // Total weeks in days divided by 7
    int days = difference.inDays % 7; // Remaining days after weeks

    // Adjust for negative months and years
    if (months < 0) {
      years--;
      months += 12;
    }

    // Determine which unit to return based on the values calculated
    if (years > 0) {
      return '$years y';
    } else if (months > 0) {
      return '$months m';
    } else if (weeks > 0) {
      return '$weeks w';
    } else {
      if (days > 1) {
        return '$days d';
      } else {
        return "Today";
      }
    }
  } else {
    return "-"; // Return a placeholder for null timestamps
  }
}
