import 'package:cloud_firestore/cloud_firestore.dart';

class BrokerRating {
  String id;
  String brokerId;
  int rate;
  Timestamp timestamp;

  BrokerRating({
    required this.id,
    required this.brokerId,
    required this.rate,
    required this.timestamp,
  });

  factory BrokerRating.fromDoc(DocumentSnapshot doc) {
    return BrokerRating(
      id: doc.id,
      brokerId: doc['brokerId'],
      rate: doc['rate'],
      timestamp: doc['timestamp'],
    );
  }
}

class ListingRating {
  String id;
  String listingId;
  int rate;
  Timestamp timestamp;

  ListingRating({
    required this.id,
    required this.listingId,
    required this.rate,
    required this.timestamp,
  });

  factory ListingRating.fromDoc(DocumentSnapshot doc) {
    return ListingRating(
      id: doc.id,
      listingId: doc['listingId'],
      rate: doc['rate'],
      timestamp: doc['timestamp'],
    );
  }
}
