class UserProfile {
  String id;
  String userId;
  String name;
  String email;
  String bio;
  String phoneNumber;
  String profilePicture;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.bio,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory UserProfile.fromDoc(Map doc) {
    return UserProfile(
      id: doc['id'],
      userId: doc['user_id'],
      name: doc['name'],
      email: doc['email'],
      bio: doc['bio'],
      phoneNumber: doc['phone_number'],
      profilePicture: doc['profilePicture'],
    );
  }
}
