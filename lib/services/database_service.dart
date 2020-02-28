import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/activity_model.dart';
import 'package:instagram/models/comment_model.dart';
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
      "likeCount": post.likeCount,
      "timestamp": post.timestamp,
      "authorId": post.authorId
    });
  }

  static Future<User> getUser(String userId) async {
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
      "name": followedUser.name,
      "profileImageUrl": followedUser.profileImageUrl
    });

    //Add currentUser to user's followers collection
    followersRef
        .document(userId)
        .collection("usersFollowers")
        .document(currentUserId)
        .setData({
      "name": followingUser.name,
      "profileImageUrl": followingUser.profileImageUrl
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
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection("usersFollowing")
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection("usersFollowers")
        .getDocuments();
    return followersSnapshot.documents.length;
  }

  static Future<QuerySnapshot> followingUsers(String userId) async {
    QuerySnapshot followingUsers = await followingRef
        .document(userId)
        .collection("usersFollowing")
        .getDocuments();

    return followingUsers;
  }

  static Future<QuerySnapshot> userFollowers(String userId) async {
    QuerySnapshot userFollowers = await followersRef
        .document(userId)
        .collection("usersFollowers")
        .getDocuments();
    return userFollowers;
  }

  static Future<List<Post>> getUserFeed(String userId) async {
    QuerySnapshot feedSnapshot = await feedsRef
        .document(userId)
        .collection("usersFeeds")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Post> feedsList =
        feedSnapshot.documents.map((doc) => Post.fromdoc(doc)).toList();
    return feedsList;
  }

  static Future<List<Post>> getUserPost(String userId) async {
    QuerySnapshot userPosts = await postsRef
        .document(userId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Post> postsList =
        userPosts.documents.map((doc) => Post.fromdoc(doc)).toList();
    return postsList;
  }

  static void likePost(String currentUserId, Post post) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection("userPosts")
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({"likeCount": likeCount + 1});
    });

    likesRef
        .document(post.id)
        .collection("postLikes")
        .document(currentUserId)
        .setData({});
    addActivityItem(currentUserId, post, null);
  }

  static void unlikePost(String currentUserId, Post post) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection("userPosts")
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({"likeCount": likeCount - 1});
    });

    likesRef
        .document(post.id)
        .collection("postLikes")
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> didLikePost(String currentUserId, Post post) async {
    DocumentSnapshot likeSnapshot = await likesRef
        .document(post.id)
        .collection("postLikes")
        .document(currentUserId)
        .get();
    return likeSnapshot.exists;
  }

  static Future<QuerySnapshot> getComments(String postId) async {
    QuerySnapshot comments = await commentsRef
        .document(postId)
        .collection("postComments")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    return comments;
  }

  static void postComment(Post post, Comment comment) {
    commentsRef.document(post.id).collection("postComments").add({
      "userId": comment.userId,
      "comment": comment.comment,
      "timestamp": Timestamp.now(),
    });
    addActivityItem(comment.userId, post, comment.comment);
  }

  static void addActivityItem(String currentUserId, Post post, String comment) {
    if (currentUserId != post.authorId) {
      activityRef.document(post.authorId).collection("userActivities").add({
        "fromUserId": currentUserId,
        "postId": post.id,
        "postImageUrl": post.imageUrl,
        "comment": comment,
        "timestamp": Timestamp.now(),
      });
    }
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot activitiesSnapshot = await activityRef
        .document(userId)
        .collection("userActivities")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Activity> activities=  activitiesSnapshot.documents.map((doc)=>Activity.fromDoc(doc)).toList();
    return activities;
  }

  static Future<Post> getSinglePost(String currentUserId ,String postId)async{
    DocumentSnapshot postSnapshot  = await postsRef.document(currentUserId).collection("userPosts").document(postId).get();
    if(postSnapshot.exists){
      return Post.fromdoc(postSnapshot);
    }
  }
}
