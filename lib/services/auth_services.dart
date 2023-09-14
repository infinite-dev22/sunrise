import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../constants/constants.dart';

class AuthServices {
  static Future<bool> createUserProfile({name}) async {
    try {
      User? signedInUser = FirebaseAuth.instance.currentUser;

      if (signedInUser != null) {
        userProfilesRef.doc(signedInUser.uid).set({
          'userId': signedInUser.uid,
          'name': signedInUser.displayName ?? name,
          'email': signedInUser.email ?? '',
          'bio': '',
          'accountType': 'broker',
          'phoneNumber': signedInUser.phoneNumber ?? '',
          'profilePicture': signedInUser.photoURL ??
              'https://firebasestorage.googleapis.com/v0/b/homepal-ff7cb.appspot.com/o/images%2Fusers%2Fplace_holder%2Fuser-placeholder.png?alt=media&token=a946179c-16f0-4794-80dd-ccf0c25471f6',
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
