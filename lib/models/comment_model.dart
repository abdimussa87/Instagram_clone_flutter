import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/user_model.dart';

class Comment {
  final String id;
  final String userId;
  final String comment;
  final Timestamp timestamp;
  Comment({this.id, this.userId, this.comment, this.timestamp});
  factory Comment.fromDoc(DocumentSnapshot documentSnapshot) {
    return Comment(
      id: documentSnapshot.documentID,
      userId: documentSnapshot["userId"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }
}
