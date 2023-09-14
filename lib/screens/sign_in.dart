import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/forgot_password.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/screens/verify_email.dart';

import '../services/auth_services.dart';
import '../services/database_services.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mfaAction = AuthStateChangeAction<MFARequired>(
      (context, state) async {
        final nav = Navigator.of(context);

        await startMFAVerification(
          resolver: state.resolver,
          context: context,
        );

        UserProfile userProfile = await DatabaseServices.getUserProfile(
            FirebaseAuth.instance.currentUser!.uid);

        nav.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => RootApp(
                      userProfile: userProfile,
                    )),
            (Route<dynamic> route) => false);
      },
    );

    final nav = Navigator.of(context);

    return SignInScreen(
      actions: [
        ForgotPasswordAction((context, email) {
          _navigateToForgotPassword(context, email);
        }),
        AuthStateChangeAction<SignedIn>((context, state) async {
          if (!state.user!.emailVerified) {
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
        }),
        AuthStateChangeAction<UserCreated>((context, state) async {
          AuthServices.createUserProfile();
          if (!state.credential.user!.emailVerified) {
            _navigateToVerifyEmail(context);
          } else {
            UserProfile userProfile = await DatabaseServices.getUserProfile(
                FirebaseAuth.instance.currentUser!.uid);
            _navigateToRootApp(nav, userProfile);
          }
        }),
        AuthStateChangeAction<CredentialLinked>((context, state) async {
          if (!state.user.emailVerified) {
            _navigateToVerifyEmail(context);
          } else {
            try {
              UserProfile userProfile = await DatabaseServices.getUserProfile(
                  FirebaseAuth.instance.currentUser!.uid);
              _navigateToRootApp(nav, userProfile);
            } catch (e) {
              AuthServices.createUserProfile();
              nav.pop();

              UserProfile userProfile = await DatabaseServices.getUserProfile(
                  FirebaseAuth.instance.currentUser!.uid);
              _navigateToRootApp(nav, userProfile);
            }
          }
        }),
        mfaAction,
      ],
      styles: const {
        EmailFormStyle(signInButtonVariant: ButtonVariant.filled, inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            action == AuthAction.signIn
                ? 'Welcome to Home Pal! Please sign in to continue.'
                : 'Welcome to Home Pal! Please create an account to continue',
          ),
        );
      },
      footerBuilder: (context, action) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              action == AuthAction.signIn
                  ? 'By signing in, you agree to our terms and conditions.'
                  : 'By registering, you agree to our terms and conditions.',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
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
        MaterialPageRoute(
            builder: (BuildContext context) => VerifyEmailPage()),
        (Route<dynamic> route) => false);
  }

  _navigateToForgotPassword(BuildContext context, String? email) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => ForgotPasswordPage(
                  email: email,
                )));
  }
}
