import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/rooms.dart';
import 'package:sunrise/screens/settings.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/bottombar_item.dart';

import 'add_listing.dart';
import 'favourite.dart';
import 'home.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int _activeTab = 0;

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
        "page": const RoomsPage(),
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
    bool showBanner = false;
    return InternetConnectivityListener(
      connectivityListener: (BuildContext context, bool hasInternetAccess) {
        if (hasInternetAccess) {
          if (showBanner) {
            showBanner = false;
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner(
                reason: MaterialBannerClosedReason.remove);
            // CherryToast.success(
            //   iconWidget: const Icon(Icons.wifi_rounded),
            //   backgroundColor: AppColor.green_700,
            //   title: const Text("You are back Online."),
            //   animationType: AnimationType.fromTop,
            // ).show(context);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_rounded),
                  SizedBox(
                    width: 20,
                  ),
                  Text("You are back Online!"),
                ],
              ),
              backgroundColor: AppColor.green_700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 140,
                  right: 20,
                  left: 20),
            ));
          }
        } else {
          showBanner = true;
          showBanner
              ? {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner(
                      reason: MaterialBannerClosedReason.remove),
                  ScaffoldMessenger.of(context)
                      .showMaterialBanner(const MaterialBanner(
                    backgroundColor: AppColor.red_500,
                    content: Text("No internet connection"),
                    actions: [Icon(Icons.wifi_off_rounded)],
                  ))
                }
              : Container();
          // context.showBanner('No internet connection', color: Colors.red);
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.appBgColor,
        body: _buildPage(),
        floatingActionButton: _buildBottomBar(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
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
        color: AppColor.bottomBarColor,
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
              setState(() {
                _activeTab = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
