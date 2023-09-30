import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants/constants.dart';

class AuthServices {
  static Future<bool> createUserProfile({name}) async {
    try {
      User? signedInUser = FirebaseAuth.instance.currentUser;

      if (signedInUser != null) {
        userProfilesRef.insert({
          'user_id': signedInUser.uid,
          'name': signedInUser.displayName ?? name,
          'email': signedInUser.email ?? '',
          'bio': '',
          'phone_number': signedInUser.phoneNumber ?? '',
          'profile_picture': signedInUser.photoURL ??
              'https://tunzmvqqhrkcdlicefmi.supabase.co/storage/v1/object/public/images/users/user-placeholder.png',
        });
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}
