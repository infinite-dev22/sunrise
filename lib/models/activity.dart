class Favorite {
  String id;
  String userId;
  String listingId;

  Favorite({
    required this.id,
    required this.userId,
    required this.listingId
  });

  factory Favorite.fromDoc(Map doc) {
    return Favorite(
      id: doc['id'],
      userId: doc['userId'],
      listingId: doc['listing_id']
    );
  }
}

class RecentlyViewed {
  String id;
  String userId;
  String listingId;

  RecentlyViewed({
    required this.id,
    required this.userId,
    required this.listingId
  });

  factory RecentlyViewed.fromDoc(Map doc) {
    return RecentlyViewed(
      id: doc['id'],
      userId: doc['userId'],
      listingId: doc['listing_id']
    );
  }
}
