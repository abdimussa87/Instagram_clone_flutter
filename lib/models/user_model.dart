import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl;
  final String bio;

  User({
    this.id,
    this.name,
    this.email,
    this.profileImageUrl,
    this.bio,
  });

 factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      email: doc['email'],
      profileImageUrl: doc['profileImageUrl'],
      bio: doc['bio'] ?? '',
    );
  }
}
