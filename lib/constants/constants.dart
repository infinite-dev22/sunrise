import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

final _fireStore = FirebaseFirestore.instance;

final usersRef = _fireStore.collection('user_profiles');

final likesRef = _fireStore.collection('likes');

final favoritesRef = _fireStore.collection('favorites');
final recentsRef = _fireStore.collection('recents');

final db = _fireStore;

final database = FirebaseDatabase.instance;

final storageRef = FirebaseStorage.instance.ref();

final listingsRef = _fireStore.collection('listings');

final featuresRefs = _fireStore.collection('features');

final listingRatingsRef = _fireStore.collection('listing_ratings');

final brokerRatingsRef = _fireStore.collection('broker_ratings');