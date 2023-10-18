import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunrise/constants/constants.dart';

import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';

class DatabaseServices {
  static void upsertUserWallet(UserProfile user, int amount) {
    walletsRef.upsert({
      'user_id': user.id,
      'balance': amount.toDouble(),
    }).execute();
  }

  static void createAccountTransaction(
      int walletId, int amount, String type, String reason, String method) {
    transactionsRef.insert({
      'wallet_id': walletId,
      'amount': amount.toDouble(),
      'type': type,
      'reason': reason,
      'method': method,
    }).execute();
  }

  static getAccountTransaction(
      int userId, int amount, String type, String reason, String method) async {
    var walletSnap = await walletsRef.select().eq('user_id', userId).execute();

    var wallets = walletSnap.data.map((doc) => Wallet.fromDoc(doc)).toList();

    return wallets;
  }

  static void updateUserData(UserProfile user) {
    userProfilesRef.update({
      'user_id': user.userId,
      'name': user.name,
      'phone_number': user.phoneNumber,
      'email': user.email,
      'bio': user.bio,
      'profile_picture': user.profilePicture,
    }).match({'id': user.id}).execute();
  }

  static getUserProfile(String userId) async {
    var userProfileDocument =
        await userProfilesRef.select().eq('user_id', userId).limit(1).execute();
    List userProfile = userProfileDocument.data
        .map((doc) => UserProfile.fromDoc(doc))
        .toList();

    if (userProfile.isNotEmpty) {
      return userProfile[0];
    } else {
      return null;
    }
  }

  static getUserProfileById(int userId) async {
    var userProfileDocument =
        await userProfilesRef.select().eq('id', userId).limit(1).execute();
    var userProfile = userProfileDocument.data
        .map((doc) => UserProfile.fromDoc(doc))
        .toList();

    return userProfile[0];
  }

  static emailExists(String email) async {
    var userProfileDocument =
        await userProfilesRef.select().eq('email', email).limit(1).execute();
    var userProfile = userProfileDocument.data
        .map((doc) => UserProfile.fromDoc(doc))
        .toList();

    print(userProfile);

    return userProfile;
  }

  static Future<List> getListingsBySearch(String search) async {
    List listings = [];
    var listingsTypeSnap = await supabase.rpc('search_listings', params: {
      'keyword': ['&@~ $search']
    }).execute();

    listings.addAll(
        listingsTypeSnap.data.map((doc) => Listing.fromDoc(doc)).toList());
    return listings;
  }

  static void addFavorite(String currentUserId, Listing? listing) {
    favoritesRef.upsert({
      'user_id': currentUserId,
      'listing_id': listing!.id,
      'updated_at': DateTime.now().toIso8601String()
    }).execute();
  }

  static void removeFavorite(
      String currentUserId, Listing? listing, int favoriteId) {
    favoritesRef
        .delete()
        .match({'user_id': currentUserId, 'listing_id': listing!.id}).execute();
  }

  static Future<void> likeListing(String currentUserId, Listing listing) async {
    var listingDocSnapshot =
        await listingsRef.select<List>('likes').eq('id', listing.id).execute();

    var data = listingDocSnapshot.data;
    int likes = data[0]['likes'];

    listingsRef
        .update({'likes': likes + 1}).match({'id': listing.id}).execute();

    addFavorite(currentUserId, listing);
  }

  static Future<void> unlikeListing(
      String currentUserId, Listing listing, int favoriteId) async {
    var listingDocSnapshot =
        await listingsRef.select<List>('likes').eq('id', listing.id).execute();

    var data = listingDocSnapshot.data;
    int likes = data[0]['likes'];

    if (likes == 0) {
      listingsRef.update({'likes': 0}).match({'id': listing.id}).execute();
    } else {
      listingsRef
          .update({'likes': likes - 1}).match({'id': listing.id}).execute();
    }

    removeFavorite(currentUserId, listing, favoriteId);
  }

  static Future<List> getAllFavorites() async {
    var listingsSnap = await favoritesRef
        .select()
        .order('created_at', ascending: false)
        .execute();

    List listings =
        listingsSnap.data.map((doc) => Favorite.fromDoc(doc)).toList();
    return listings;
  }

  static Future<List> getFavorites() async {
    List listings = [];

    var snapShots = await favoritesRef
        .select()
        .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
        .order('created_at', ascending: false)
        .execute();

    listings = snapShots.data.map((doc) => Favorite.fromDoc(doc)).toList();
    return listings;
  }

  static getUserFavorites() async {
    var favoritesSnap = await favoritesRef
        .select()
        .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
        .order('created_at', ascending: false)
        .execute();
    var favorites =
        favoritesSnap.data.map((doc) => Favorite.fromDoc(doc)).toList();

    return favorites;
  }

  static void createListing(Listing listing, var onSuccess, var onError) {
    listingsRef.insert({
      "user_id": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'price_normal': listing.priceNormal,
      'bedrooms': listing.bedrooms,
      'bathrooms': listing.bathrooms,
      'kitchens': listing.kitchens,
      'garages': listing.garages,
      'size_unit': listing.sizeUnit,
      'size': listing.size,
      'currency': listing.currency,
      'status': listing.status,
      'property_type': listing.propertyType,
      'property_use': listing.propertyUse,
      'year_constructed': listing.yearConstructed,
      'description': listing.description,
      'is_property_owner': listing.isPropertyOwner,
      'likes': listing.likes,
      'featured': listing.featured,
      'show': listing.show,
      'features': listing.features,
      'features_two': listing.features2,
      'images': listing.images
    }).execute().onError((error, stackTrace) => onError).then((value) => onSuccess);
  }

  static updateListing(Listing listing) async {
    listingsRef.update({
      "user_id": listing.userId,
      'name': listing.name,
      'location': listing.location,
      'price': listing.price,
      'price_normal': listing.priceNormal,
      'bedrooms': listing.bedrooms,
      'bathrooms': listing.bathrooms,
      'kitchens': listing.kitchens,
      'garages': listing.garages,
      'size_unit': listing.sizeUnit,
      'size': listing.size,
      'currency': listing.currency,
      'status': listing.status,
      'property_type': listing.propertyType,
      'property_use': listing.propertyUse,
      'year_constructed': listing.yearConstructed,
      'description': listing.description,
      'is_property_owner': listing.isPropertyOwner,
      'likes': listing.likes,
      'featured': listing.featured,
      'show': listing.show,
      'features': listing.features,
      'features_two': listing.features2,
      'images': listing.images
    }).match({'id': listing.id}).execute();
  }

  static deleteListing(Listing listing) async {
    var docSnapshot =
        await listingsRef.select<List>().eq('id', listing.id).execute();

    var item = docSnapshot.data[0];
    item['show'] = false;

    updateListing(Listing.fromDoc(item));

    recentsRef.delete().match({'id': listing.id}).execute();
  }

  static Future<void> addRecent(String currentUserId, Listing listing) async {
    recentsRef.upsert({
      'user_id': currentUserId,
      'listing_id': listing.id,
      'updated_at': DateTime.now().toIso8601String()
    }).execute();
  }

  static Future<List> getFavorite(int listingId) async {
    var favoritesSnap =
        await favoritesRef.select().eq('listing_id', listingId).execute();

    List favorites =
        favoritesSnap.data.map((doc) => Favorite.fromDoc(doc)).toList();
    return favorites;
  }

  static Future<List> getListing() async {
    var listingsSnap = await listingsRef
        .select()
        .order('created_at', ascending: false)
        .execute();

    List listings =
        listingsSnap.data.map((doc) => Listing.fromDoc(doc)).toList();
    return listings;
  }
}
