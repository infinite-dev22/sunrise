import 'dart:async';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sunrise/screens/login.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/screens/sign_up.dart';
import 'package:sunrise/screens/verify_email.dart';
import 'package:toast/toast.dart';

import '../models/account.dart';
import '../services/auth_services.dart';
import '../services/database_services.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_square_tile.dart';
import '../widgets/auth_textfield.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  final ToastContext toast = ToastContext();

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final double _sigmaX = 5; // from 0-10
  final double _sigmaY = 5; // from 0-10
  final double _opacity = 0.2;
  final _formKey = GlobalKey<FormState>();

  // sign user in method
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, 1)
                                .withOpacity(_opacity),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30))),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Form(
                          key: _formKey,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Sign in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(height: 10),
                                AuthTextField(
                                  controller: emailController,
                                  hintText: 'Email',
                                  obscureText: false,
                                  isEmail: true,
                                ),
                                const SizedBox(height: 10),
                                AuthButton(
                                  onTap: (() async {
                                    var nav = Navigator.of(context);
                                    if (_formKey.currentState!.validate()) {
                                      if (EmailValidator.validate(
                                          emailController.text)) {
                                        List<String> userList =
                                            await FirebaseAuth.instance
                                                .fetchSignInMethodsForEmail(
                                                    emailController.text);

                                        if (userList.isEmpty) {
                                          nav.push(
                                            MaterialPageRoute(
                                                builder: (context) => Signup(
                                                      email:
                                                          emailController.text,
                                                    )),
                                          );
                                        } else {
                                          nav.push(
                                            MaterialPageRoute(
                                                builder: (context) => LoginPage(
                                                      email: emailController
                                                          .text
                                                          .trim(),
                                                    )),
                                          );
                                        }
                                      } else {
                                        Toast.show("Email not valid",
                                            duration: Toast.lengthLong,
                                            gravity: Toast.bottom);
                                      }
                                    }
                                  }),
                                ),

                                const SizedBox(height: 5),

                                // or continue with
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.5,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        'Or',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.5,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                // google + apple sign in buttons
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // google button
                                      AuthSquareTile(
                                        imagePath: 'assets/images/google.png',
                                        title: "Continue with Google",
                                        onTap: () {
                                          signInWithGoogle();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // not a member? register now
                                Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        // ignore: prefer_const_literals_to_create_immutables
                                        children: [
                                          const Text(
                                            'Don\'t have an account?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                            textAlign: TextAlign.start,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Signup()));
                                              },
                                              child: const Text('Sign Up',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 71, 233, 133),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                  textAlign: TextAlign.start)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  checkAuthStatus(BuildContext context) {
    final nav = Navigator.of(context);

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (!user.emailVerified) {
          _navigateToVerifyEmail(context);
        } else {
          try {
            UserProfile userProfile =
                await DatabaseServices.emailExists(user.email!);
            userProfile.userId = user.uid;
            DatabaseServices.updateUserData(userProfile);

            _navigateToRootApp(nav, userProfile);
          } catch (e) {
            var userProfile = await AuthServices.createUserProfile();

            DatabaseServices.upsertUserWallet(userProfile, 0);
            _navigateToRootApp(nav, userProfile);
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

  _navigateToVerifyEmail(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => const VerifyEmailPage()),
        (Route<dynamic> route) => false);
  }
}
