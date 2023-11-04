import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sunrise/models/account.dart';

import '../constants/constants.dart';

class AuthServices {
  static createUserProfile({name}) async {
    try {
      User? signedInUser = FirebaseAuth.instance.currentUser;

      if (signedInUser != null) {
        List userProfileList = await userProfilesRef.insert({
          'user_id': signedInUser.uid,
          'name': signedInUser.displayName ?? name,
          'email': signedInUser.email ?? '',
          'bio': '',
          'phone_number': signedInUser.phoneNumber ?? '',
          'profile_picture': signedInUser.photoURL ??
              'https://tunzmvqqhrkcdlicefmi.supabase.co/storage/v1/object/public/images/users/user-placeholder.png',
        }).select();
        UserProfile userProfile =
            userProfileList.first.map((e) => UserProfile.fromDoc(e));
        return userProfile;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }
}
