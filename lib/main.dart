import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/constants/constants.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/screens/verify_email.dart';
import 'package:sunrise/services/auth_services.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'models/account.dart';

final actionCodeSettings = ActionCodeSettings(
  handleCodeInApp: true,
  androidMinimumVersion: '1',
  androidPackageName: 'org.infinite.sunrise',
  url: 'https://flutterfire-e2e-tests.firebaseapp.com',
);

Future<void> main() async {
  // Initialize firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://tunzmvqqhrkcdlicefmi.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1bnptdnFxaHJrY2RsaWNlZm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU1NzkyMjAsImV4cCI6MjAxMTE1NTIyMH0.3IF3LnGSD38zWRW7vQElmRFJFQNOI4l82uAxoPUoqmM");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();

  if (FirebaseAuth.instance.currentUser != null) {
    // Get user profile.
    UserProfile userProfile = await DatabaseServices.getUserProfile(
        FirebaseAuth.instance.currentUser!.uid);

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

    if (auth.currentUser != null) {
      if (!auth.currentUser!.emailVerified && auth.currentUser!.email != null) {
        return VerifyEmailPage();
      }

      return RootApp(userProfile: userProfile);
    } else {
      return const RootApp(userProfile: null);
    }
  }
}

///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Icon(
                      Icons.notifications_active,
                      size: MediaQuery.of(context).size.height * 0.3,
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Allow HomePal to send you notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewProgressNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          // -1 is replaced by a random number
          channelKey: 'alerts',
          title: 'Uploading Listing Ad',
          notificationLayout: NotificationLayout.ProgressBar,
          payload: {
            'notificationId': 'DCRTd53EDc638ec5d5cHGeecs6es^C4wc45edj'
          }),
    );
  }

  static Future<void> createNewDoneNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          // -1 is replaced by a random number
          channelKey: 'alerts',
          title: 'Upload Complete.',
          //'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.Default,
          payload: {
            'notificationId': 'HbkhGYUhIy87y7888UHOIUyn89y87YHon87y87'
          }),
    );
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> dismissNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
  }
}
