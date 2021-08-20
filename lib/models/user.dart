import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String photoUrl;
  final String bio;
  final String email;
  final String displayName;

  User(
      {required this.id,
      required this.username,
      required this.bio,
      required this.email,
      required this.displayName,
      required this.photoUrl});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        username: doc['username'],
        bio: doc['bio'],
        email: doc['email'],
        displayName: doc['displayName'],
        photoUrl: doc['photoUrl']);
  }
}
