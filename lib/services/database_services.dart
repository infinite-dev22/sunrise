import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunrise/constants/constants.dart';

import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';

class DatabaseServices {
  static void updateUserData(UserProfile user) {
    userProfilesRef.update({
      'name': user.name,
      'phoneNumber': user.phoneNumber,
      'email': user.email,
      'bio': user.bio,
      'profilePicture': user.profilePicture,
    }).match({'user_id': user.id});
  }

  static getUserProfile(String userId) async {
    var userProfileDocument = await userProfilesRef.select().eq('user_id', userId);
    var userProfile =
        userProfileDocument.docs.map((value) => UserProfile.fromDoc(value));

    return userProfile;
  }

  static Future<List> getListingsBySearch(String search) async {
    List<Listing> listings = [];

    var listingsTypeSnap = await listingsRef.select()
        .textSearch("propertyType", search);

    var listingsPriceSnap1 = await listingsRef.select()
        .textSearch("price_normal", search);

    var listingsPriceSnap2 = await listingsRef.select()
        .textSearch("price", search);

    var listingsNameSnap = await listingsRef.select()
        .textSearch("name", search);

    var listingsLocationSnap = await listingsRef.select()
        .textSearch("location", search);

    var listingsStatusSnap = await listingsRef.select()
        .textSearch("status", search);

    var listingsBrokersSnap = await listingsRef.select()
        .textSearch("name", search);

    listings.addAll(
        listingsTypeSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsNameSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsLocationSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsStatusSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsPriceSnap1.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings.addAll(
        listingsPriceSnap2.docs.map((doc) => Listing.fromDoc(doc)).toList());
    listings
        .addAll(listingsBrokersSnap.docs.map((doc) => Listing.fromDoc(doc)).toList());
    return listings;
  }

  static Future<List<Favorite>> getLikes(String userId) async {
    var userLikesSnapshot = await likesRef.select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);

    List<Favorite> likes =
        userLikesSnapshot.docs.map((doc) => Favorite.fromDoc(doc)).toList();

    return likes;
  }

  static void addFavorite(String currentUserId, Listing? listing) {
    favoritesRef
        .insert({
      'userId': currentUserId,
      'listingId': listing!.id,
      "like": true,
    });
    likesRef.insert({
      'userId': currentUserId,
      'listingId': listing.id,
      "like": true,
    });
  }

  static void removeFavorite(
      String currentUserId, Listing? listing, String favoriteId) {
    favoritesRef.delete()
        .match({'user_id': currentUserId, 'listing_id': listing!.id});
    likesRef.delete().match({'user_id': listing.userId, 'listing_id': listing.id});
  }

  static Future<void> likeListing(String currentUserId, Listing listing) async {
    var listingDocSnapshot =
    await listingsRef.select().eq('listing_id', listing.id);

    Map<String, dynamic>? data = listingDocSnapshot.data();

    int likes = data?["likes"];

    listingDocSnapshot.update({'likes': likes + 1});

    addFavorite(currentUserId, listing);
  }

  static Future<void> unlikeListing(
      String currentUserId, Listing listing, String favoriteId) async {
    var listingDocSnapshot =
    await listingsRef.select().eq('listing_id', listing.id);

    Map<String, dynamic>? data = listingDocSnapshot.data();

    int likes = data?["likes"];

    if (likes == 0) {
      listingDocSnapshot.update({'likes': 0});
    } else {
      listingDocSnapshot.update({'likes': likes - 1});
    }

    removeFavorite(currentUserId, listing, favoriteId);
  }

  static Future<List> getAllFavorites() async {
    var listingsSnap = await favoritesRef.select()
        .order('timestamp', ascending: false);

    List<Favorite> listings =
        listingsSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    return listings;
  }

  static Future<List> getFavorites() async {
    List<Favorite> listings = [];

    var snapShots = await favoritesRef.select()
        .eq('id', FirebaseAuth.instance.currentUser!.uid)
        .order('timestamp', ascending: false);

      listings = snapShots.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    return listings;
  }

  static getUserFavorites() async {
    var favoritesSnap = await favoritesRef.select()
        .eq('id', FirebaseAuth.instance.currentUser!.uid)
        .order('timestamp', ascending: false);
    var favorites =
        favoritesSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();

    return favorites;
  }

  static void createListing(Listing listing) {
    listingsRef.insert({
      "brokerId": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'priceNormal': listing.priceNormal,
      'bedrooms': listing.bedrooms,
      'bathrooms': listing.bathrooms,
      'kitchens': listing.kitchens,
      'garages': listing.garages,
      'sizeUnit': listing.sizeUnit,
      'size': listing.size,
      'currency': listing.currency,
      'status': listing.status,
      'propertyType': listing.propertyType,
      'propertyUse': listing.propertyUse,
      'yearConstructed': listing.yearConstructed,
      'description': listing.description,
      'isPropertyOwner': listing.isPropertyOwner,
      'likes': listing.likes,
      'featured': listing.featured,
      'show': listing.show,
      'features': listing.features,
      'features2': listing.features2,
      'images': listing.images
    });
  }

  static updateListing(Listing listing) async {
    listingsRef.update({
      "brokerId": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'priceNormal': listing.priceNormal,
      'bedrooms': listing.bedrooms,
      'bathrooms': listing.bathrooms,
      'kitchens': listing.kitchens,
      'garages': listing.garages,
      'sizeUnit': listing.sizeUnit,
      'size': listing.size,
      'currency': listing.currency,
      'status': listing.status,
      'propertyType': listing.propertyType,
      'propertyUse': listing.propertyUse,
      'yearConstructed': listing.yearConstructed,
      'description': listing.description,
      'isPropertyOwner': listing.isPropertyOwner,
      'likes': listing.likes,
      'featured': listing.featured,
      'show': listing.show,
      'features': listing.features,
      'features2': listing.features2,
      'images': listing.images
    }).match({'id': listing.id});
  }

  static deleteListing(Listing listing) async {
    // for (var image in listing.images) {
    //   storageRef
    //       .child(
    //           "images/listings/${listing.userId}/${image.toString().substring(image.toString().lastIndexOf("listing_"), image.toString().lastIndexOf("?"))}")
    //       .delete();
    // }

    var docSnapshot = await listingsRef.select(listing.id);

    Listing item = docSnapshot.then((doc) => Listing.fromDoc(doc));
    item.show = false;
    updateListing(item);

    recentsRef.delete().match({'id': listing.id});
  }

  static void addRecent(String currentUserId, Listing listing) {
    recentsRef.insert({
      'userId': currentUserId,
      'listingId': listing.id
    });
  }

  static Future<List> getUserRecents() async {
    List<Favorite> listings = [];

    Stream snapShots = await recentsRef
        .select()
        .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
        .order('timestamp', ascending: false)
        .asStream();

    snapShots.listen((event) {
      listings = event.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    });
    return listings;
  }

  static deleteUserRecents() {
    recentsRef.delete().match({'id': supabase.auth.currentUser!.id});
  }

  static Future<List> getFavorite(String listingId) async {
    var favoritesSnap = await favoritesRef
        .select()
        .eq('listing_id', listingId);

    List<Favorite> favorites =
        favoritesSnap.docs.map((doc) => Favorite.fromDoc(doc)).toList();
    return favorites;
  }

  static Future<List> getListing() async {
    var listingsSnap = await listingsRef.select()
        .order('timestamp', ascending: false);

    List<Listing> listings =
        listingsSnap.docs.map((doc) => Listing.fromDoc(doc)).toList();
    return listings;
  }
}
