import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  String userId;
  String name;
  String email;
  String bio;
  String accountType;
  String phoneNumber;
  String profilePicture;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.bio,
    required this.accountType,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    return UserProfile(
      id: doc.id,
      userId: doc['userId'],
      name: doc['name'],
      email: doc['email'],
      bio: doc['bio'],
      accountType: doc['accountType'],
      phoneNumber: doc['phoneNumber'],
      profilePicture: doc['profilePicture'],
    );
  }
}
