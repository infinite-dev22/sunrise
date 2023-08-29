import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

getAuthUser() {
  return  FirebaseAuth.instance.currentUser;
}

getAuthUserName() {
  return user?.displayName;
}
