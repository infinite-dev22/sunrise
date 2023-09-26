import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final userProfilesRef = supabase.from('user_profiles');

final likesRef = supabase.from('likes');

final usersRef = supabase.from('users');

final favoritesRef = supabase.from('favorites');
final recentsRef = supabase.from('recents');

final db = supabase;

final listingsRef = supabase.from('listings');

final featuresRefs = supabase.from('features');

final listingRatingsRef = supabase.from('listing_ratings');

final brokerRatingsRef = supabase.from('broker_ratings');