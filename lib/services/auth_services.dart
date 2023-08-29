import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sunrise/utilities/global_values.dart';

import '../constants/constants.dart';

class AuthServices {
  static Future<bool> createUserProfile() async {
    try {
      User? signedInUser = getAuthUser();

      if (signedInUser != null) {
        usersRef.doc(signedInUser.uid).set({
          'userId': signedInUser.uid ?? '',
          'name': signedInUser.displayName ?? '',
          'email': signedInUser.email ?? '',
          'bio': '',
          'accountType': 'broker',
          'phoneNumber': signedInUser.phoneNumber ?? '',
          'profilePicture': signedInUser.photoURL ?? '',
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
