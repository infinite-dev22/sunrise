import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sunrise/constants/constants.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/admin.dart';
import 'package:sunrise/screens/profile.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/widgets/custom_image.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/color.dart';
import '../widgets/settings_section.dart';
import 'detail.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.userProfile});

  final UserProfile? userProfile;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ToastContext toast = ToastContext();

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        title: Text(
          "Settings",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _buildSettings(),
    );
  }

  _buildUser() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          color: Colors.red),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20),
                child: CustomImage(widget.userProfile!.profilePicture),
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 213,
                        child: Text(
                          widget.userProfile!.name,
                          softWrap: true,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis),
                        )),
                    const SizedBox(height: 5),
                    Text(
                      widget.userProfile!.email,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                color: Colors.white),
            child: SettingsItem(
              icons: Icons.edit,
              iconStyle: IconStyle(
                withBackground: true,
                borderRadius: 50,
                backgroundColor: Colors.yellow[600],
              ),
              title: "Modify",
              subtitle: "Tap to change your data",
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          ProfilePage(userProfile: widget.userProfile!),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildSettings() {
    return SettingsList(
      applicationType: ApplicationType.both,
      lightTheme:
          const SettingsThemeData(settingsListBackground: AppColor.appBgColor),
      sections: [
        CustomSettingsSection(
          child: Column(
            children: [
              if (widget.userProfile != null) _buildUser(),
            ],
          ),
        ),
        if (kDebugMode)
          CustomSettingsSection(
            child: RaisedSettingsSection(
              children: [
                SettingsTile.navigation(
                  leading: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: AppColor.blue_500,
                        borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.shield_rounded,
                        color: AppColor.blue_700),
                  ),
                  title: const Text("My Admin"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: (context) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              AdminApp(userProfile: widget.userProfile!),
                        ));
                  },
                ),
              ],
            ),
          ),
        CustomSettingsSection(
          child: RaisedSettingsSection(
            children: [
              SettingsTile.navigation(
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColor.blue_300,
                      borderRadius: BorderRadius.circular(50)),
                  child:
                      const Icon(Icons.notifications, color: AppColor.blue_700),
                ),
                title: const Text("Notification"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
              SettingsTile.navigation(
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColor.red_500,
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.privacy_tip_sharp,
                      color: AppColor.red_700),
                ),
                title: const Text("Privacy Policy"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: (context) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const DetailPage(
                          showingContent: 'Privacy Policy',
                        ),
                      ));
                },
              ),
              SettingsTile.navigation(
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColor.purple_500,
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.info_rounded,
                      color: AppColor.purple_700),
                ),
                title: const Text("About"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: (context) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const DetailPage(
                          showingContent: 'About',
                        ),
                      ));
                },
              ),
            ],
          ),
        ),
        CustomSettingsSection(
          child: RaisedSettingsSection(
            children: [
              SettingsTile.navigation(
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColor.orange_500,
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(CupertinoIcons.chat_bubble_fill,
                      color: AppColor.orange_700),
                ),
                title: const Text("Send Feedback"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: (context) {
                  launchUrl(Uri(
                    scheme: "mailto",
                    path: "support@homepal.org",
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Feedback mail',
                    }),
                  ));
                },
              ),
            ],
          ),
        ),
        CustomSettingsSection(
          child: RaisedSettingsSection(
            children: [
              SettingsTile.navigation(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: const Text("Sign Out"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: (context) {
                  _signOutAccountConfirmationDialog();
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.delete_solid),
                title: const Text(
                  "Delete account",
                  style: TextStyle(color: AppColor.red_700),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: (context) {
                  _deleteAccountConfirmationDialog();
                },
              ),
            ],
          ),
        ),
        const CustomSettingsSection(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  _deleteAccountConfirmationDialog() {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.error,
      title: "Delete",
      desc:
          "Are you sure you want to delete your account?\nThis action can't be undone.",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: AppColor.red_700,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            _deleteAccount();
            _signOut();
            _deleteSuccessDialog();
          },
          color: AppColor.green_700,
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _signOutAccountConfirmationDialog() {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.info,
      title: "Sign Out",
      desc: "You are signing out of your profile.",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: AppColor.red_700,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            _signOut();
            _buildHomePage();
          },
          color: AppColor.green_700,
          child: const Text(
            "Proceed",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _deleteSuccessDialog() {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.success,
      title: "Success",
      desc: "Your account has successfully been deleted.",
      buttons: [
        DialogButton(
          onPressed: () {
            _buildHomePage();
          },
          color: AppColor.green_700,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _deleteAccount() async {
    try {
      await usersRef.doc(FirebaseAuth.instance.currentUser!.uid).delete();
      await userProfilesRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseAuth.instance.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        Toast.show("Requires recent login to continue.",
            duration: Toast.lengthLong, gravity: Toast.bottom);
        await _reAuthenticateAndDelete();
      } else {
        if (kDebugMode) {
          print(e.toString());
        }
        Toast.show("An error occurred!",
            duration: Toast.lengthLong, gravity: Toast.bottom);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      Toast.show("An error occurred!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  Future<void> _reAuthenticateAndDelete() async {
    try {
      final providerData =
          FirebaseAuth.instance.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      Toast.show("An error occurred!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  _buildHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => const RootApp()),
        (Route<dynamic> route) => false);
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
