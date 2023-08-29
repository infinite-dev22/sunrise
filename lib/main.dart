import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, GoogleAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/screens/sign_in.dart';
import 'package:sunrise/screens/verify_email.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/global_values.dart';

import 'firebase_options.dart';
import 'models/account.dart';

final actionCodeSettings = ActionCodeSettings(
  handleCodeInApp: true,
  androidMinimumVersion: '1',
  androidPackageName: 'com.example.sunrise_broker',
  url: 'https://flutterfire-e2e-tests.firebaseapp.com',
);

Future<void> main() async {
  const GOOGLE_CLIENT_ID =
      "632689866596-ocq6qpeqmo8chh8e0vdmtmk7u3ov6lco.apps.googleusercontent.com";

  // Initialize firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Firebase Auth Providers.
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: GOOGLE_CLIENT_ID),
  ]);

  // local notifications.
  await PlatformNotifier.I.init(appName: "sunrise");
  await PlatformNotifier.I.requestPermissions();

  if (FirebaseAuth.instance.currentUser != null) {
    // Get user profile.
    UserProfile userProfile = await DatabaseServices.getUserProfile(user!.uid);

    // Run app UI.
    runApp(MyApp(userProfile: userProfile));
  } else {
    // Run app UI.
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.userProfile});

  final UserProfile? userProfile;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The navigator key is necessary to allow to navigate through static methods
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Home Pals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.appBgColor),
        useMaterial3: true,
        primaryColor: AppColor.primary,
      ),
      home: _home(),
    );
  }

  _home() {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      return const SignInPage();
    }

    if (!auth.currentUser!.emailVerified && auth.currentUser!.email != null) {
      return const VerifyEmailPage();
    }

    return RootApp(userProfile: userProfile!);
  }
}
