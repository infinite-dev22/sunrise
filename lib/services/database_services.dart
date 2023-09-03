import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunrise/constants/constants.dart';

import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';

class DatabaseServices {
  static Future<int> likesNumber(String propertyId) async {
    QuerySnapshot likesSnapshot =
        await likesRef.doc(propertyId).collection('PropertyLikes').get();
    return likesSnapshot.docs.length;
  }

  static void updateUserData(UserProfile user) {
    usersRef.doc(user.id).update({
      'name': user.name,
      'phoneNumber': user.phoneNumber,
      'email': user.email,
      'bio': user.bio,
      'profilePicture': user.profilePicture,
    });
  }

  static getUserProfile(String userId) {
    var userProfileDocument = usersRef.doc(userId);
    var userProfile =
        userProfileDocument.get().then((value) => UserProfile.fromDoc(value));

    return userProfile;
  }

  static Future<QuerySnapshot> searchListingsByName(String name) async {
    Future<QuerySnapshot> listings = listingsRef
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: '${name}z')
        .get();

    return listings;
  }

  static Future<QuerySnapshot> searchListingsByPrice(String price) async {
    Future<QuerySnapshot> listings =
        listingsRef.where('price', isEqualTo: price).get();

    return listings;
  }

  static Future<QuerySnapshot> searchListingsByLocation(String location) async {
    Future<QuerySnapshot> listings = listingsRef
        .where('location', isEqualTo: location)
        .where('location', isLessThan: '${location}z')
        .get();

    return listings;
  }

  static void favoriteListing(String currentUserId, Listing listing) {
    likesRef.doc(listing.userId).collection('Likes').doc(listing.id).set({});
    favoritesRef
        .doc(listing.id)
        .collection('Favorites')
        .doc(currentUserId)
        .set({});

    addFavorite(currentUserId, listing);
  }

  static void unFavoriteListing(String currentUserId, String listingId) {
    likesRef
        .doc(currentUserId)
        .collection('Likes')
        .doc(listingId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    favoritesRef
        .doc(listingId)
        .collection('Favorites')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isLikingListing(
      String currentUserId, String listingId) async {
    DocumentSnapshot likingDoc = await favoritesRef
        .doc(listingId)
        .collection('Favorites')
        .doc(currentUserId)
        .get();
    return likingDoc.exists;
  }

  static getUserListings(String brokerId) async {
    QuerySnapshot brokerListingsSnap = await listingsRef
        .doc(brokerId)
        .collection('Listings')
        .orderBy('timestamp', descending: true)
        .get();
    var brokerListings =
        brokerListingsSnap.docs.map((doc) => Listing.fromDoc(doc)).toList();

    return brokerListings;
  }

  static Future<List> getListings() async {
    QuerySnapshot listingsSnap = await db
        .collectionGroup('Listings')
        .orderBy('timestamp', descending: true)
        .get();

    List<Listing> listings =
        listingsSnap.docs.map((doc) => Listing.fromDoc(doc)).toList();
    return listings;
  }

  static Future<List> getUsers() async {
    List<Listing> listings = [];

    db
        .collectionGroup('users')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((event) {
      listings = event.docs.map((doc) => Listing.fromDoc(doc)).toList();
    });
    return listings;
  }

  static Future<List> getListingsBySearch(String search) async {
    List<Listing> listings = [];

    QuerySnapshot listingsTypeSnap = await db
        .collectionGroup('Listings')
        .where("propertyType", isGreaterThanOrEqualTo: search)
        .get();

    QuerySnapshot listingsNameSnap = await db
        .collectionGroup('Listings')
        .where("name", isGreaterThanOrEqualTo: search)
        .get();

    QuerySnapshot listingsLocationSnap = await db
        .collectionGroup('Listings')
        .where("location", isGreaterThanOrEqualTo: search)
        .get();

    QuerySnapshot listingsStatusSnap = await db
        .collectionGroup('Listings')
        .where("status", isGreaterThanOrEqualTo: search)
        .get();

    QuerySnapshot brokersSnap = await db
        .collectionGroup('Users')
        .where("accountType", isEqualTo: "broker")
        .where("name", isGreaterThanOrEqualTo: search)
        .get();

    listings.addAll(
        listingsTypeSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsNameSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsLocationSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsStatusSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings
        .addAll(brokersSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    return listings;
  }

  static Future<List<Favorite>> getLikes(String userId) async {
    QuerySnapshot userLikesSnapshot = await likesRef
        .doc(userId)
        .collection('Likes')
        .orderBy('timestamp', descending: true)
        .get();

    List<Favorite> likes =
        userLikesSnapshot.docs.map((doc) => Favorite.fromDoc(doc)).toList();

    return likes;
  }

  static void addFavorite(String currentUserId, Listing? listing) {
    favoritesRef
        .doc(currentUserId)
        .collection('Favorites')
        .doc(listing!.id)
        .set({
      'userId': currentUserId,
      'listingId': listing.id,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      "like": true,
    });
    likesRef.doc(listing.userId).collection('Likes').doc(listing.id).set({
      'userId': currentUserId,
      'listingId': listing.id,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      "like": true,
    });
  }

  static void removeFavorite(
      String currentUserId, Listing? listing, String favoriteId) {
    favoritesRef
        .doc(currentUserId)
        .collection('Favorites')
        .doc(listing!.id)
        .delete();
    likesRef.doc(listing.userId).collection('Likes').doc(listing.id).delete();
  }

  static Future<void> likeListing(String currentUserId, Listing listing) async {
    var listingDocCollection =
        listingsRef.doc(listing.userId).collection('Listings').doc(listing.id);

    DocumentSnapshot<Map<String, dynamic>> listingDocSnapshot =
        await listingDocCollection.get();

    Map<String, dynamic>? data = listingDocSnapshot.data();

    int likes = data?["likes"];

    listingDocCollection.update({'likes': likes + 1});

    addFavorite(currentUserId, listing);
  }

  static Future<void> unlikeListing(
      String currentUserId, Listing listing, String favoriteId) async {
    var listingDocCollection =
        listingsRef.doc(listing.userId).collection('Listings').doc(listing.id);
    DocumentSnapshot<Map<String, dynamic>> listingDocSnapshot =
        await listingDocCollection.get();

    Map<String, dynamic>? data = listingDocSnapshot.data();

    int likes = data?["likes"];

    if (likes == 0) {
      listingDocCollection.update({'likes': 0});
    } else {
      listingDocCollection.update({'likes': likes - 1});
    }

    removeFavorite(currentUserId, listing, favoriteId);
  }

  static Future<List> getAllFavorites() async {
    QuerySnapshot listingsSnap = await db
        .collectionGroup('Favorites')
        .orderBy('timestamp', descending: true)
        .get();

    List<Favorite> listings =
        listingsSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    return listings;
  }

  static Future<List> getFavorites() async {
    List<Favorite> listings = [];

    var snapShots = db
        .collection("favorites")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Favorites')
        .orderBy('timestamp', descending: true)
        .snapshots();

    snapShots.listen((event) {
      listings = event.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    });
    return listings;
  }

  static getUserFavorites() async {
    QuerySnapshot favoritesSnap = await favoritesRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Favorites')
        .orderBy('timestamp', descending: true)
        .get();
    var favorites =
        favoritesSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();

    return favorites;
  }

  static void createListing(Listing listing) {
    listingsRef.doc(listing.userId).set({'listingTime': listing.timestamp});
    listingsRef.doc(listing.userId).collection('Listings').add({
      "brokerId": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'currency': listing.currency,
      'status': listing.status,
      'propertyType': listing.propertyType,
      'propertyUse': listing.propertyUse,
      'yearConstructed': listing.yearConstructed,
      'description': listing.description,
      'likes': listing.likes,
      'featured': listing.featured,
      'features': listing.features,
      'images': listing.images,
      "timestamp": listing.timestamp,
    });
  }

  static updateListing(Listing listing) async {
    listingsRef
        .doc(listing.userId)
        .collection('Listings')
        .doc(listing.id)
        .update({
      "brokerId": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'currency': listing.currency,
      'status': listing.status,
      'propertyType': listing.propertyType,
      'propertyUse': listing.propertyUse,
      'yearConstructed': listing.yearConstructed,
      'description': listing.description,
      'likes': listing.likes,
      'featured': listing.featured,
      'features': listing.features,
      'images': listing.images,
      "timestamp": listing.timestamp,
    });
  }

  static deleteListing(Listing listing) {
    for (var image in listing.images) {
      storageRef
          .child(
              "images/listings/${listing.userId}/${image.toString().substring(image.toString().lastIndexOf("listing_"), image.toString().lastIndexOf("?"))}")
          .delete();
    }

    listingsRef
        .doc(listing.userId)
        .collection('Listings')
        .doc(listing.id)
        .delete();

    db.collection('recents').doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }

  static void addRecent(String currentUserId, Listing listing) {
    recentsRef.doc(currentUserId).collection('Recents').doc(listing.id).set({
      'userId': currentUserId,
      'listingId': listing.id,
      'timestamp': Timestamp.fromDate(DateTime.now())
    });
  }

  static Future<List> getUserRecents() async {
    List<Favorite> listings = [];

    Stream snapShots = db
        .collection("recents")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Recents')
        .orderBy('timestamp', descending: true)
        .snapshots();

    snapShots.listen((event) {
      listings = event.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    });
    return listings;
  }

  static deleteUserRecents() {
    recentsRef.doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }

  static Future<List> getFavorite(String listingId) async {
    QuerySnapshot favoritesSnap = await favoritesRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Favorites')
        .where("listingId", isEqualTo: listingId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Favorite> favorites =
        favoritesSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    return favorites;
  }

  static Future<List> getListing() async {
    QuerySnapshot listingsSnap = await db
        .collectionGroup('Listings')
        .orderBy('timestamp', descending: true)
        .get();

    List<Listing> listings =
        listingsSnap.docs.map((doc) => Listing.fromDoc(doc)).toList();
    return listings;
  }
}
