import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/rooms.dart';
import 'package:sunrise/screens/settings.dart';
import 'package:sunrise/screens/welcome.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/bottombar_item.dart';
import 'package:toast/toast.dart';

import 'add_listing.dart';
import 'favourite.dart';
import 'home.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key, this.userProfile}) : super(key: key);

  final UserProfile? userProfile;

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  ToastContext toast = ToastContext();
  int _activeTab = 0;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  _barItems() {
    return [
      {
        "icon": Icons.home_outlined,
        "active_icon": Icons.home_rounded,
        "page": HomePage(userProfile: widget.userProfile),
      },
      {
        "icon": Icons.favorite_border,
        "active_icon": Icons.favorite_outlined,
        "page": FavouritePage(userProfile: widget.userProfile),
      },
      {
        "icon": Icons.add_box_outlined,
        "active_icon": Icons.add_box_rounded,
        "page": AddListingPage(userProfile: widget.userProfile),
      },
      {
        "icon": Icons.forum_outlined,
        "active_icon": Icons.forum_rounded,
        "page": RoomsPage(userProfile: widget.userProfile),
      },
      {
        "icon": Icons.settings_outlined,
        "active_icon": Icons.settings_rounded,
        "page": SettingsPage(userProfile: widget.userProfile),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    toast.init(context);
    _checkNetwork();

    return RefreshIndicator(
      onRefresh: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => super.widget)),
      child: InternetConnectivityListener(
        connectivityListener: (BuildContext context, bool hasInternetAccess) {
          if (isDeviceConnected && !hasInternetAccess) {
            Toast.show("Your internet connection is unstable",
                duration: 10,
                gravity: Toast.top,
                backgroundColor: Colors.black.withOpacity(.8));
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.appBgColor,
          body: DoubleBack(
            message: 'Tap back again to exit',
            child: _buildPage(),
          ),
          floatingActionButton: _buildBottomBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
        ),
      ),
    );
  }

  _checkNetwork() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      Toast.show("You are back Online",
          duration: Toast.lengthLong,
          gravity: Toast.top,
          backgroundColor: Colors.green.withOpacity(.8));
    } else {
      Toast.show("No internet connection",
          duration: 10, gravity: Toast.top, backgroundColor: Colors.red.shade900.withOpacity(.8));
    }
  }

  Widget _buildPage() {
    return IndexedStack(
      index: _activeTab,
      children: List.generate(
        _barItems().length,
        (index) => _barItems()[index]["page"],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 55,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
      decoration: BoxDecoration(
        color: AppColor.appBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          _barItems().length,
          (index) => BottomBarItem(
            _activeTab == index
                ? _barItems()[index]["active_icon"]
                : _barItems()[index]["icon"],
            isActive: _activeTab == index,
            activeColor: AppColor.primary,
            onTap: () {
              if (index == 1 || index == 2 || index == 3 || index == 4) {
                if (FirebaseAuth.instance.currentUser == null) {
                  _buildSignInModal();
                } else {
                  setState(() {
                    _activeTab = index;
                  });
                }
              } else {
                setState(() {
                  _activeTab = index;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  _buildSignInModal() {
    return showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        height: 230,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const Text(
              "Sign In Required To Continue!",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => AppColor.green_700)),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(),
                    )),
                child: const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => AppColor.red_700)),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox();
        setState(() => isAlertSet = true);
      }
    });
  }

  showDialogBox() => showAdaptiveDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }
}
