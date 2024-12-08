import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pintresto/dialogs/information_bar.dart';
import 'package:pintresto/models/post_model.dart';
import 'package:pintresto/models/tag_model.dart';
import 'package:pintresto/models/user_model.dart';

class SearchServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//* search for a tag post create
  Future<List<TagModel>> searchTags(
      String searchTerm, BuildContext context) async {
    searchTerm = searchTerm.toLowerCase();
    if (searchTerm == "") {
      return [];
    }
    try {
      // Query the 'tags' collection where document ID starts with the searchTerm
      QuerySnapshot querySnapshot = await _firestore
          .collection('tags')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: searchTerm)
          .where(FieldPath.documentId,
              isLessThanOrEqualTo:
                  '$searchTerm\uf8ff') // Range query for matching tags
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Convert documents to a list of maps where each map is { id: documentId, data: documentData }
        List<Map<String, dynamic>> tagsMap = querySnapshot.docs.map((doc) {
          return {"id": doc.id, "data": doc.data() as Map<String, dynamic>};
        }).toList();

        // Convert maps to TagModel instances
        List<TagModel> tags =
            tagsMap.map((tagMap) => TagModel.fromJson(tagMap)).toList();

        return tags; // Returns a list of TagModel instances
      } else {
        return [];
      }
    } catch (e) {
      // informationBar(context, "Couldn't searching for tags $e");
      return [];
    }
  }

  //* search by name
  Future<List<PostModel>> getPostsByPartialNameOrTags({
    required String searchName,
    required BuildContext context,
  }) async {
    try {
      List<Map<String, dynamic>> allPosts = [];

      // Fetch all posts from the "Pins" collection
      QuerySnapshot querySnapshot = await _firestore.collection("Pins").get();

      // Process each post
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;

        // Get the post's title and tags
        String title = postData['title'] ?? '';
        List<dynamic> tags = postData['selectedTags'] ?? [];

        // Check if the title or tags contain the search term (case-insensitive)
        bool matchesTitle =
            title.toLowerCase().contains(searchName.toLowerCase());
        bool matchesTags = tags.any((tag) =>
            tag.toString().toLowerCase().contains(searchName.toLowerCase()));

        // If it matches either the title or tags, proceed to fetch the owner's details
        if (matchesTitle || matchesTags) {
          String ownerId = postData['ownerId'] ?? '';

          if (ownerId.isNotEmpty) {
            // Fetch the corresponding user document using ownerId
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .doc(ownerId)
                .get();

            if (userSnapshot.exists) {
              // Get ownerName and ownerPfp from the user document
              String ownerName = userSnapshot['userName'] ?? '';
              String ownerPfp = userSnapshot['pfpUrl'] ?? '';

              // Add ownerName and ownerPfp to the post data
              postData['ownerName'] = ownerName;
              postData['ownerPfp'] = ownerPfp;
            }
          }
          // Add the post to the list after updating with owner info
          allPosts.add(postData);
        }
      }
      // Map post data to PostModel and return the list
      return allPosts.map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      // informationBar(context, "Error fetching posts by name or tags: $e");
      return [];
    }
  }

//* update search history for people
  Future<Map<String, dynamic>> searchPeopleByName(
      {required String searchName, required BuildContext context}) async {
    searchName = searchName.toLowerCase();
    try {
      List<UserModel> allUsers = [];
      int searchCount = 0; // Variable to hold the search frequency
      // Fetch all users from the "users" collection
      QuerySnapshot userQuerySnapshot =
          await _firestore.collection("users").get();

      // Process each user
      for (var doc in userQuerySnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        // Get the user's name
        String userName = userData['userName'] ?? '';

        // Check if the user's name contains the search term (case-insensitive)
        if (userName.toLowerCase().contains(searchName.toLowerCase()) &&
            userData["isVisible"]) {
          // Add user data to the list
          allUsers.add(UserModel.fromJson(userData));
        }
      }

      // Fetch matching search terms from the "SearchTerms" collection
      QuerySnapshot searchTermsSnapshot = await _firestore
          .collection("Search")
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: searchName)
          .where(FieldPath.documentId,
              isLessThan:
                  '${searchName}z') // Use 'z' to ensure we get only those starting with searchName
          .orderBy(FieldPath
              .documentId) // Order by document ID (i.e., the search term)
          .limit(10) // Limit to 10 results
          .get();

      List<String> matchedSearchTerms = [];

      // Process each matching search term
      for (var termDoc in searchTermsSnapshot.docs) {
        matchedSearchTerms
            .add(termDoc.id); // Store the matched term (document ID)
      }

      // Return a map with users list and search count
      return {
        'users': allUsers,
        'searchedCount': searchCount,
        'matchedSearchTerms':
            matchedSearchTerms, // Include matched search terms
      };
    } catch (e) {
      // informationBar(context, "Error searching users by name: $e");
      return {
        'users': <UserModel>[],
        'searchedCount': 0,
        'matchedSearchTerms': <String>[],
      };
    }
  }

  //* update search
  Future<void> updateSearchCounter(
      {required searchTerm, required BuildContext context}) async {
    try {
      DocumentSnapshot docRef =
          await _firestore.collection("Search").doc(searchTerm).get();
      if (docRef.exists) {
        DocumentReference searchRef =
            _firestore.collection("Search").doc(searchTerm);
        //* update the counter
        await searchRef.update({"searched": FieldValue.increment(1)});
      } else {
        //* add it
        DocumentReference searchRef =
            _firestore.collection("Search").doc(searchTerm);
        await searchRef.set({"searched": 1});
      }
    } catch (e) {
      // informationBar(context, "Failed to update search counter $e");
    }
  }

// Get top search terms with unique post images
  Future<Map<String, String?>> getTopSearchTerms(BuildContext context) async {
    try {
      // Fetch the search terms from the 'tags' collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("tags")
          .orderBy("used", descending: true)
          .limit(8) // Limit to 8 results
          .get();

      // Initialize a map to store tag names and their corresponding post image URLs
      Map<String, String?> tagPostMap = {};
      Set<String> usedPostIds = {}; // Track used post IDs

      // Loop through each tag
      for (var doc in querySnapshot.docs) {
        String tagName = doc.id;

        // Fetch posts associated with the tag
        QuerySnapshot postSnapshot = await FirebaseFirestore.instance
            .collection("Pins")
            .where("selectedTags",
                arrayContains:
                    tagName) // Assuming 'tags' is an array field in your posts
            .get();

        // Find a post that hasn't been used yet
        for (var postDoc in postSnapshot.docs) {
          String postId = postDoc.id; // Get the post ID
          if (!usedPostIds.contains(postId)) {
            // Extract post data
            Map<String, dynamic> postData =
                postDoc.data() as Map<String, dynamic>;

            // Get the image URL (assuming the field is named 'imageUrl')
            String? imageUrl = postData["imageUrl"];
            tagPostMap[tagName] =
                imageUrl; // Map the tag to its corresponding image URL

            usedPostIds.add(postId); // Mark this post ID as used
            break; // Move to the next tag after finding a unique post
          }
        }

        // If no unique post is found for the tag, set it to null
        if (!tagPostMap.containsKey(tagName)) {
          tagPostMap[tagName] = null; // Or set to a default image URL
        }
      }

      return tagPostMap; // Return the map containing tag names and image URLs
    } catch (e) {
      // Handle error
      // informationBar(context,"Error fetching top search terms: $e");
      return {}; // Return an empty map on error
    }
  }

  //* create a tag
  Future<TagModel?> createCostumeTag(
      {required String tag, required BuildContext context}) async {
    try {
      DocumentReference docRef =
          _firestore.collection("tags").doc(tag.toLowerCase());
      await docRef.set({"used": 1});
      return TagModel(name: tag, usedCount: 1);
    } catch (e) {
      informationBar(context, "Error :$e");
      return null;
    }
  }

  //*
}
