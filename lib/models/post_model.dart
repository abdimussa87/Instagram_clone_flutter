import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final String authorId;
  final Timestamp timestamp;
  final int likeCount;

  Post({
    this.id,
    this.imageUrl,
    this.caption,
    this.authorId,
    this.timestamp,
    this.likeCount,
  });

  factory Post.fromdoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      caption: doc['caption'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
      likeCount: doc['likeCount'],
    );
  }
}
