// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sunrise/screens/login.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/screens/sign_up.dart';
import 'package:sunrise/screens/verify_email.dart';
import 'package:toast/toast.dart';
import 'package:twitter_login/twitter_login.dart';

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
  final usernameController = TextEditingController();
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
                            color: Color.fromRGBO(0, 0, 0, 1)
                                .withOpacity(_opacity),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.72,
                        child: Form(
                          key: _formKey,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
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
                                  controller: usernameController,
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
                                          usernameController.text)) {
                                        List<String> userList =
                                            await FirebaseAuth.instance
                                                .fetchSignInMethodsForEmail(
                                                    usernameController.text);

                                        if (userList.isEmpty) {
                                          nav.push(
                                            MaterialPageRoute(
                                                builder: (context) => Signup(
                                                      email: usernameController
                                                          .text,
                                                    )),
                                          );
                                        } else {
                                          nav.push(
                                            MaterialPageRoute(
                                                builder: (context) => LoginPage(
                                                      email: usernameController
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
                                      // facebook button
                                      AuthSquareTile(
                                        imagePath: 'assets/images/facebook.png',
                                        title: "Continue with Facebook",
                                        onTap: () {
                                          signInWithFacebook();
                                        },
                                      ),
                                      SizedBox(height: 10),

                                      // google button
                                      AuthSquareTile(
                                        imagePath: 'assets/images/google.png',
                                        title: "Continue with Google",
                                        onTap: () {
                                          signInWithGoogle();
                                        },
                                      ),

                                      SizedBox(height: 10),

                                      // apple button
                                      AuthSquareTile(
                                        imagePath: 'assets/images/x.png',
                                        title: "Continue with X",
                                        onTap: () {
                                          signInWithTwitter();
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
                                          Text(
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
                                                            Signup()));
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

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult =
        await FacebookAuth.instance.login(permissions: ['email']);

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = TwitterLogin(
        apiKey: 'YhQMA2T9Y3gntRQpzOoUMaW32',
        apiSecretKey: 'PE9hkQyH7lUk2RwsL9sukp5tZRYNaGnIhwtYJeIwU18pukBzHP',
        redirectURI: 'https://homepal-ff7cb.firebaseapp.com/__/auth/handler');

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(twitterAuthCredential);
  }

  checkAuthStatus(BuildContext context) {
    final nav = Navigator.of(context);

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (!user.emailVerified) {
          _navigateToVerifyEmail(context);
        } else {
          try {
            UserProfile userProfile = await DatabaseServices.getUserProfile(
                FirebaseAuth.instance.currentUser!.uid);
            _navigateToRootApp(nav, userProfile);
          } catch (e) {
            AuthServices.createUserProfile();

            UserProfile userProfile = await DatabaseServices.getUserProfile(
                FirebaseAuth.instance.currentUser!.uid);
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
        MaterialPageRoute(builder: (BuildContext context) => VerifyEmailPage()),
        (Route<dynamic> route) => false);
  }
}
