import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../constants/constants.dart';

class AuthServices {
  static Future<bool> createUserProfile({name}) async {
    try {
      User? signedInUser = FirebaseAuth.instance.currentUser;

      if (signedInUser != null) {
        userProfilesRef.insert({
          'userId': signedInUser.uid,
          'name': signedInUser.displayName ?? name,
          'email': signedInUser.email ?? '',
          'bio': '',
          'accountType': 'broker',
          'phoneNumber': signedInUser.phoneNumber ?? '',
          'profilePicture': signedInUser.photoURL ??
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
