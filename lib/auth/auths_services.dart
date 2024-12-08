import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //* create user information section
  Future<void> saveUserData(
      {required String id,
      required BuildContext context,
      required String userName,
      required String? pfpUrl}) async {
    // create user model
    UserModel userInfo = UserModel(
        userName: userName,
        pfpUrl: pfpUrl ?? "",
        email: _auth.currentUser!.email!,
        userId: id,
        followersIds: [],
        followingIds: [],
        likedPosts: [],
        notifications: [],
        chatsIds: [],
        userPins: [],
        favorites: [],
        yourBoards: [],
        drafts: [],
        savedPins: []);
    // save the data to the firestore
    try {
      DocumentSnapshot docSnap =
          await _firestore.collection("users").doc(id).get();
      if (!docSnap.exists) {
        // Create a document with the user's email as the document ID
        await _firestore.collection('users').doc(id).set(userInfo.toJson());
      }
    } catch (e) {
      informationBar(context, 'Error saving user to Firestore: $e');
    }
  }

  //* Save user data to Firestore
  Future<void> _saveUserToFirestore(
      {required String email,
      required bool isGoogleSignIn,
      required BuildContext context}) async {
    try {
      // Create a document with the user's email as the document ID
      await _firestore.collection('usersData').doc(email).set({
        'isGoogleSignIn': isGoogleSignIn,
      });
    } catch (e) {
      informationBar(context, "Error: $e");
    }
  }

  //* Sign in with Google
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Save user to Firestore with `isGoogleSignIn = true`
      await _saveUserToFirestore(
        email: userCredential.user?.email ?? '',
        context: context,
        isGoogleSignIn: true,
      );
      // save the user data
      User? userQuickUse = userCredential.user;
      if (userQuickUse != null) {
      await saveUserData(
            id: userQuickUse.uid,
            pfpUrl: userQuickUse.photoURL,
            context: context,
            userName: userQuickUse.displayName!);
      }
      informationBar(context, "Sign In as ${userQuickUse!.displayName}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      //* it throw a mounted error if use snack bar here for some reason
      informationBar(context, "Error: ${e.code}");
      return null;
    }
  }

  //* Sign up with email, password, and username
  Future<User?> signUpWithEmail(String email, String password, String username,
      BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      userCredential.user!.updateDisplayName(username);

      // Save user to Firestore with `isGoogleSignIn = false`
      await _saveUserToFirestore(
        email: userCredential.user?.email ?? '',
        context: context,
        isGoogleSignIn: false,
      );
      // save use data
      User? userQuickUse = userCredential.user;
      if (userQuickUse != null) {
        saveUserData(
            id: userQuickUse.uid,
            pfpUrl: "",
            userName: username,
            context: context);
      }
      informationBar(context, "Account Created");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      informationBar(context, "Error: ${e.code}");
      return null;
    }
  }

  //* Sign in with email and password
  Future<User?> signInWithEmail(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Ensure user exists in Firestore and update `isGoogleSignIn = false`
      await _saveUserToFirestore(
        email: userCredential.user?.email ?? '',
        context: context,
        isGoogleSignIn: false,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        informationBar(context, "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        informationBar(context, 'Wrong password provided for that user.');
      } else {
        informationBar(context, "Error: ${e.code}");
      }
      return null;
    }
  }

  //* Fetch user data by email
  Future<String?> fetchUserData(String email) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('usersData').doc(email).get();
      if (userDoc.exists) {
        if (userDoc["isGoogleSignIn"]) {
          return "1";
        } else {
          return "2";
        }
      } else {
        return "3";
      }
    } on FirebaseException catch (e) {
      return e.code;
    }
  }

  //* Forget email (reset password)
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      informationBar(context, "Reset Email were sent to $email");
    } on FirebaseAuthException catch (e) {
      informationBar(context, "Error sending the reset Email : ${e.code}");
    }
  }

  //* Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      informationBar(context, "Log Out");
    } on FirebaseAuthException catch (e) {
      informationBar(context, "Error: ${e.code}");
    }
  }

  //* check if user signed in
  Future<bool> isUserSignedIn() async {
    return _auth.currentUser != null;
  }

  //* get current user
  Future<User?> getTheCurrentUser() async {
    return _auth.currentUser;
  }

  //* get current user id
  String getTheCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  //* is the current user
  bool checkIfItsUser({required String userId}) {
    return userId == _auth.currentUser!.uid;
  }

  //* update password
  Future<bool> updatePassword({required String password}) async {
    await _auth.currentUser!.updatePassword(password);
    return true;
  }
}
