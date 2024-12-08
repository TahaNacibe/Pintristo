import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _profilePictureUrl = '';
  String _username = '';
  bool _updateHappen = false;

  String get profilePictureUrl => _profilePictureUrl;
  String get username => _username;
  bool get updateHappen => _updateHappen;

  // Method to manually reset the update flag
  void resetUpdateHappen() {
    _updateHappen = false; // Reset the flag after checking
    notifyListeners(); // Notify listeners to rebuild UI if necessary
  }

  // Method to mark that an update has occurred
  void updateChange() {
    _updateHappen = true; // Set the update flag to true
    // Use addPostFrameCallback to notify after build is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // Notify listeners after the current frame
    });
  }

  // Method to update user data
  Future<void> updateUserData(String newProfilePictureUrl, String newUsername) async {
    _profilePictureUrl = newProfilePictureUrl;
    _username = newUsername;
    updateChange(); // Mark that an update has happened
    // Use addPostFrameCallback to notify after build is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // Notify listeners after the current frame
    });
  }
}
