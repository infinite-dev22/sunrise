class Listing {
  String id;
  String userId;
  String name;
  String location;
  String price;
  String priceNormal;
  String bedrooms;
  String bathrooms;
  String kitchens;
  String garages;
  String sizeUnit;
  String size;
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
  List<dynamic> features2;
  List<dynamic> images;

  Listing({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.price,
    required this.priceNormal,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.garages,
    required this.sizeUnit,
    required this.size,
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
    required this.features2,
    required this.images
  });

  factory Listing.fromDoc(Map doc) {
    return Listing(
      id: doc['id'],
      userId: doc['broker_id'],
      name: doc['name'],
      location: doc['location'],
      price: doc['price'],
      priceNormal: doc['price_normal'],
      bedrooms: doc['bedrooms'],
      bathrooms: doc['bathrooms'],
      kitchens: doc['kitchens'],
      garages: doc['garages'],
      sizeUnit: doc['size_unit'],
      size: doc['size'],
      currency: doc['currency'],
      status: doc['status'],
      propertyType: doc['property_type'],
      propertyUse: doc['property_use'],
      yearConstructed: doc['year_constructed'],
      description: doc['description'],
      isPropertyOwner: doc['is_property_owner'],
      likes: doc['likes'],
      featured: doc['featured'],
      show: doc['show'],
      features: doc['features'],
      features2: doc['features_two'],
      images: doc['images']
    );
  }
}
