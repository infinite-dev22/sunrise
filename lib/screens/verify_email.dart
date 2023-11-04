import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/root.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../models/account.dart';
import '../services/auth_services.dart';
import '../services/database_services.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final ToastContext toast = ToastContext();
  late Timer _timer;
  User? user = FirebaseAuth.instance.currentUser;
  var duration = const Duration(seconds: 30);
  late bool sentEmail;

  @override
  Widget build(BuildContext context) {
    const double sigmaX = 5; // from 0-10
    const double sigmaY = 5; // from 0-10
    const double opacity = 0.2;

    toast.init(context);
    checkAuthStatus(context);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/auth_back.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.17),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Verify Your Email",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: sigmaX, sigmaY: sigmaY),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 1)
                                        .withOpacity(opacity),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30))),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                          "A verification email has"
                                          " been sent to your"
                                          " email address. Please"
                                          " check your email and"
                                          " click on the link to"
                                          " verify your email"
                                          " address.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          overflow: TextOverflow.clip,
                                          softWrap: true),
                                      const SizedBox(height: 30),
                                      const CircularProgressIndicator(
                                        color:
                                            Color.fromARGB(255, 71, 233, 133),
                                      ),
                                      const SizedBox(height: 30),
                                      TextButton(
                                          onPressed: () {
                                            if (user != null) {
                                              FirebaseAuth.instance.currentUser!
                                                  .sendEmailVerification();
                                            }
                                          },
                                          child: const Text(
                                              'Resend Verification Email',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 71, 233, 133),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                              textAlign: TextAlign.start)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  checkAuthStatus(BuildContext context) {
    final nav = Navigator.of(context);

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (user.emailVerified) {
          Toast.show("Email verified successfully",
              duration: Toast.lengthLong, gravity: Toast.bottom);

          List<UserProfile> userProfiles =
              await DatabaseServices.emailExists(user.email!);

          if (userProfiles.isNotEmpty) {
            UserProfile userProfile = userProfiles[0];
            userProfile.userId = user.uid;
            DatabaseServices.updateUserData(userProfile);
          } else {
            var userProfile1 =
                await AuthServices.createUserProfile(name: user.email);
            DatabaseServices.upsertUserWallet(userProfile1, 0);
          }

          UserProfile userProfile = await DatabaseServices.getUserProfile(
              FirebaseAuth.instance.currentUser!.uid);
          _navigateToRootApp(nav, userProfile);
        } else {
          if (sentEmail) {
            // if (duration.inSeconds == 0) {
            //   await user.sendEmailVerification();
            // }
            // } else {
            sentEmail = false;
            await user.sendEmailVerification();
          }
        }
      }
    });
  }

  _navigateToRootApp(NavigatorState nav, UserProfile userProfile) {
    nav.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => RootApp(
                  userProfile: userProfile,
                )),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    sentEmail = true;

    super.initState();

    var nav = Navigator.of(context);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        timer.cancel();

        Toast.show("Email verified successfully",
            duration: Toast.lengthLong, gravity: Toast.bottom);

        List userProfiles = await DatabaseServices.emailExists(user!.email!);

        if (userProfiles.isNotEmpty) {
          UserProfile userProfile = userProfiles[0];
          userProfile.userId = user.uid;
          DatabaseServices.updateUserData(userProfile);
        } else {
          await AuthServices.createUserProfile(name: userName);

          UserProfile userProfile = await DatabaseServices.getUserProfile(
              FirebaseAuth.instance.currentUser!.uid);

          DatabaseServices.upsertUserWallet(userProfile, 0);
        }

        UserProfile userProfile = await DatabaseServices.getUserProfile(
            FirebaseAuth.instance.currentUser!.uid);
        _navigateToRootApp(nav, userProfile);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer.cancel();
  }
}
