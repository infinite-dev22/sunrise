class Favorite {
  int id;
  String userId;
  int listingId;

  Favorite({
    required this.id,
    required this.userId,
    required this.listingId
  });

  factory Favorite.fromDoc(Map doc) {
    return Favorite(
      id: doc['id'],
      userId: doc['user_id'],
      listingId: doc['listing_id']
    );
  }
}

class RecentlyViewed {
  int id;
  String userId;
  int listingId;

  RecentlyViewed({
    required this.id,
    required this.userId,
    required this.listingId
  });

  factory RecentlyViewed.fromDoc(Map doc) {
    return RecentlyViewed(
      id: doc['id'],
      userId: doc['user_id'],
      listingId: doc['listing_id']
    );
  }
}
