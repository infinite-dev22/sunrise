import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/dashboard.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/bottombar_item.dart';

import 'ads.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  // int _activeTab = 0;
  int _activeTab = 1;

  _barItems() {
    return [
      {
        "icon": Icons.space_dashboard_outlined,
        "active_icon": Icons.space_dashboard_rounded,
        "page": DashboardPage(userProfile: widget.userProfile),
      },
      {
        "icon": Icons.list_outlined,
        "active_icon": Icons.view_list_rounded,
        "page": AdsPage(userProfile: widget.userProfile),
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: _buildPage(),
      // floatingActionButton: _buildBottomBar(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
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
