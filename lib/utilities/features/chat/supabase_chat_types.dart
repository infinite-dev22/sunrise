class Room {
  int id;
  String userId;
  String guestUserId;
  String userName;
  String guestUserName;
  int listingId;
  String listingName;
  bool hasNewMessages;
  String userImage;
  String guestUserImage;

  Room({
    required this.id,
    required this.userId,
    required this.guestUserId,
    required this.userName,
    required this.guestUserName,
    required this.listingId,
    required this.listingName,
    required this.hasNewMessages,
    required this.userImage,
    required this.guestUserImage,
  });

  factory Room.fromDoc(Map doc) {
    return Room(
      id: doc['id'],
      userId: doc['user_id'],
      guestUserId: doc['guest_user_id'],
      userName: doc['user_name'],
      guestUserName: doc['guest_user_name'],
      listingId: doc['listing_id'],
      listingName: doc['listing_name'],
      hasNewMessages: doc['has_new_messages'],
      userImage: doc['user_image'],
      guestUserImage: doc['guest_user_image'],
    );
  }
}
