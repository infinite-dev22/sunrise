import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  String id;
  String userId;
  String listingId;
  bool like;
  Timestamp timestamp;

  Favorite({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.like,
    required this.timestamp,
  });

  factory Favorite.fromDoc(DocumentSnapshot doc) {
    return Favorite(
      id: doc.id,
      userId: doc['userId'],
      listingId: doc['listingId'],
      like: doc['like'],
      timestamp: doc['timestamp'],
    );
  }
}

class RecentlyViewed {
  String id;
  String userId;
  String listingId;
  Timestamp timestamp;

  RecentlyViewed({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.timestamp,
  });

  factory RecentlyViewed.fromDoc(DocumentSnapshot doc) {
    return RecentlyViewed(
      id: doc.id,
      userId: doc['userId'],
      listingId: doc['listingId'],
      timestamp: doc['timestamp'],
    );
  }
}
