import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

// var supabaseUrl = "https://tunzmvqqhrkcdlicefmi.supabase.co";
// var supabaseKey =
//     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1bnptdnFxaHJrY2RsaWNlZm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU1NzkyMjAsImV4cCI6MjAxMTE1NTIyMH0.3IF3LnGSD38zWRW7vQElmRFJFQNOI4l82uAxoPUoqmM";
// SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseKey);

final userProfilesRef = supabase.from('user_profiles');
final favoritesRef = supabase.from('favorites');
final recentsRef = supabase.from('recently_viewed');
final listingsRef = supabase.from('listings');
final chatRoomsRef = supabase.from('chat_rooms');
final messagesRef = supabase.from('messages');