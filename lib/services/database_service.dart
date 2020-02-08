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

  static Future<QuerySnapshot> searchUsers(String name){
    Future<QuerySnapshot> users = usersRef.where('name',isGreaterThanOrEqualTo: name).getDocuments();
    return users;
  }

  static void createPost(Post post){
    postsRef.document(post.authorId).collection("userPosts").add({
      "imageUrl":post.imageUrl,
      "caption":post.caption,
      "likes":post.likes,
      "timestamp":post.timestamp,
      "authorId":post.authorId
    });
  }
}
