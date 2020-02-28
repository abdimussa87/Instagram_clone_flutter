import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String postId;
  final String postImageUrl;
  final String fromUserId;
  final String comment;
  final Timestamp timestamp;

  Activity({
    this.id,
    this.postId,
    this.postImageUrl,
    this.fromUserId,
    this.comment,
    this.timestamp,
  });

  factory Activity.fromDoc(DocumentSnapshot doc) {
    return Activity(
        id: doc.documentID,
        fromUserId: doc["fromUserId"],
        postId: doc["postId"],
        postImageUrl: doc["postImageUrl"],
        comment: doc["comment"],
        timestamp: doc["timestamp"]);
  }
}
