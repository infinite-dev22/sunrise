import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

getAuthUser() {
  User? usr;
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    usr = user;
  });
  return usr;
}

getAuthUserName() {
  return FirebaseAuth.instance.currentUser?.displayName;
}
