import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants/constants.dart';

class AuthServices {
  static Future<bool> createUserProfile() async {
    try {
      User? signedInUser = FirebaseAuth.instance.currentUser;

      if (signedInUser != null) {
        usersRef.doc(signedInUser.uid).set({
          'userId': signedInUser.uid,
          'name': signedInUser.displayName ?? '',
          'email': signedInUser.email ?? '',
          'bio': '',
          'accountType': 'broker',
          'phoneNumber': signedInUser.phoneNumber ?? '',
          'profilePicture': signedInUser.photoURL ??
              'https://firebasestorage.googleapis.com/v0/b/homepal-ug.appspot.com/o/images%2Fusers%2Fuser-placeholder.png?alt=media&token=36801737-2fe3-49cc-8d9e-c784ede1e630',
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
