import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/utitlities/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersRef.document(user.id).updateData({
      'name': user.name,
      'bio': user.bio,
      'profileImageUrl': user.profileImageUrl,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users =
        usersRef.where('name', isGreaterThanOrEqualTo: name).getDocuments();
    return users;
  }

  static void createPost(Post post) {
    postsRef.document(post.authorId).collection("userPosts").add({
      "imageUrl": post.imageUrl,
      "caption": post.caption,
      "likes": post.likes,
      "timestamp": post.timestamp,
      "authorId": post.authorId
    });
  }
  static Future<User> getUser(String userId) async{
    DocumentSnapshot userSnapshot = await usersRef.document(userId).get();
    User user = User.fromDoc(userSnapshot);
    return user;
  }

  static Future<bool> isFollowingUser(
      String currentUserId, String userId) async {
    DocumentSnapshot doc = await followingRef
        .document(currentUserId)
        .collection("usersFollowing")
        .document(userId)
        .get();
    return doc.exists;
  }

  static void followUser(String currentUserId, String userId) async {
    User followingUser = await getUser(currentUserId);
    User followedUser = await getUser(userId);
    
    //Add user to current user's following collection
    followingRef
        .document(currentUserId)
        .collection("usersFollowing")
        .document(userId)
        .setData({
          "name":followedUser.name,
          "profileImageUrl":followedUser.profileImageUrl
        });

    //Add currentUser to user's followers collection
    followersRef
        .document(userId)
        .collection("usersFollowers")
        .document(currentUserId)
        .setData({
          "name":followingUser.name,
          "profileImageUrl":followingUser.profileImageUrl
        });
  }

  static void unfollowUser(String currentUserId, String userId) {
    //Remove user from current user's following collection
    followingRef
        .document(currentUserId)
        .collection("usersFollowing")
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Add currentUser to user's followers collection
    followersRef
        .document(userId)
        .collection("usersFollowers")
        .document(currentUserId)
        .get().then((doc){
          if(doc.exists){
            doc.reference.delete();
          }
        });
  }

  static Future<int> numFollowing(String userId) async{
    QuerySnapshot followingSnapshot = await followingRef.document(userId).collection("usersFollowing").getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async{
    QuerySnapshot followersSnapshot = await followersRef.document(userId).collection("usersFollowers").getDocuments();
    return followersSnapshot.documents.length;
  }


  static Future<QuerySnapshot> followingUsers(String userId) async{
    QuerySnapshot followingUsers = await followingRef.document(userId).collection("usersFollowing").getDocuments();

    return followingUsers;
  }

  static Future<QuerySnapshot> userFollowers(String userId) async{
    QuerySnapshot userFollowers = await followersRef.document(userId).collection("usersFollowers").getDocuments();
    return userFollowers;
  }
}
