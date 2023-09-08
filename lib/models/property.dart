import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String id;
  String userId;
  String name;
  String location;
  String price;
  String currency;
  String propertyType;
  String propertyUse;
  String status;
  String yearConstructed;
  String description;
  String isPropertyOwner;
  int likes;
  bool featured;
  bool show;
  List<dynamic> features;
  List<dynamic> images;
  Timestamp timestamp;

  Listing({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.price,
    required this.currency,
    required this.status,
    required this.propertyType,
    required this.propertyUse,
    required this.yearConstructed,
    required this.description,
    required this.isPropertyOwner,
    required this.likes,
    required this.featured,
    required this.show,
    required this.features,
    required this.images,
    required this.timestamp,
  });

  factory Listing.fromDoc(DocumentSnapshot doc) {
    return Listing(
      id: doc.id,
      userId: doc['brokerId'],
      name: doc['name'],
      location: doc['location'],
      price: doc['price'],
      currency: doc['currency'],
      status: doc['status'],
      propertyType: doc['propertyType'],
      propertyUse: doc['propertyUse'],
      yearConstructed: doc['yearConstructed'],
      description: doc['description'],
      isPropertyOwner: doc['isPropertyOwner'],
      likes: doc['likes'],
      featured: doc['featured'],
      show: doc['show'],
      features: doc['features'],
      images: doc['images'],
      timestamp: doc['timestamp'],
    );
  }
}
