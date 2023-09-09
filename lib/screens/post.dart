import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/root.dart';
import 'package:sunrise/theme/color.dart';

import '../main.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/custom_photo_gallery.dart';
import '../widgets/wide_button.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.listing, required this.userProfile});

  final Listing listing;
  final UserProfile userProfile;

  @override
  State<StatefulWidget> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Ad"),
      ),
      backgroundColor: AppColor.appBgColor,
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Column(
      children: [
        WideButton(
          "Post Ad",
          color: AppColor.darker,
          bgColor: Colors.white,
          onPressed: () {
            _uploadListingAd();
          },
        ),
        const SizedBox(
          height: 20,
        ),
        WideButton(
          "Promote Ad \$10/week",
          color: Colors.white,
          bgColor: AppColor.green_500,
          onPressed: () {
            widget.listing.featured = true;
            _uploadListingAd();
          },
        ),
        const SizedBox(
          height: 20,
        ),
        WideButton(
          "Promote Ad \$30/month",
          color: Colors.white,
          bgColor: AppColor.green_700,
          onPressed: () {
            widget.listing.featured = true;
            _uploadListingAd();
          },
        ),
      ],
    );
  }

  _uploadListingAd() {
    setState(() {
      _loading = true;
    });
    _loading
        ? {
            showDialog(
                barrierDismissible: false,
                builder: (ctx) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                context: context),
      _showProgressUploadingNotification()
          }
        : const SizedBox.shrink();

    DatabaseServices.createListing(widget.listing);

    _showCompleteUploadNotification();

    _navigateToRootPage();
  }

  _showProgressUploadingNotification() async {
    await NotificationController.dismissNotifications();
    await NotificationController.createNewProgressNotification();
  }

  _showCompleteUploadNotification() async {
    await NotificationController.dismissNotifications();
    await NotificationController.createNewDoneNotification();
  }

  _navigateToRootPage() {
    var nav = Navigator.of(context);
    nav.pop();
    nav.push(CupertinoPageRoute(
      builder: (context) => RootApp(
        userProfile: widget.userProfile,
      ),
    ));
  }

  @override
  void dispose() {
    CustomPhotoGallery.images.clear();
    setState(() {
      _loading = false;
    });

    super.dispose();
  }
}
