import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/profile.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/custom_image.dart';
import 'package:sunrise/widgets/custom_textbox.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/dashboard_item.dart';
import 'explore.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  ToastContext toast = ToastContext();

  late Widget _current;

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: AppColor.appBgColor,
          pinned: true,
          snap: true,
          floating: true,
          title: _buildHeader(),
        ),
        SliverToBoxAdapter(child: _buildBody())
      ],
    );
  }

  _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextBox(
                hint: "Search properties",
                prefix: const Icon(Icons.search, color: Colors.grey),
                suffix: const SizedBox.shrink(),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _setListings(value);
                    } else {
                      _setListings("All");
                    }
                  });
                },
                autoFocus: false,
                onTap: () {
                  _buildNavigateToSearchPage();
                },
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            CustomImage(
              widget.userProfile.profilePicture,
              width: 35,
              height: 35,
              trBackground: true,
              borderColor: AppColor.primary,
              radius: 10,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ProfilePage(userProfile: widget.userProfile),
                ));
              },
            )
          ],
        ),
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _showPopulars(),
          _showFeatured(),
          if (FirebaseAuth.instance.currentUser != null) _showRecentlyAdded(),
          _showListings(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _buildNavigateToViewPage(Listing listing) async {
    List favorite = [];

    var nav = Navigator.of(context);

    // These variables below affect performance significantly, try putting them
    // into their respective screen(ViewPage).
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(listing.userId);

    if (FirebaseAuth.instance.currentUser != null) {
      favorite = await DatabaseServices.getFavorite(listing.id);
    }

    return nav.push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: listing,
              brokerProfile: brokerProfile,
              favorite: favorite.isEmpty ? null : favorite[0],
            )));
  }

  _buildNavigateToExplorePage(String displayContent) {
    return Navigator.of(context).push(CupertinoPageRoute(
      builder: (BuildContext context) =>
          ExplorePage(showingContent: displayContent),
    ));
  }

  _buildNavigateToSearchPage() {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const SearchPage(),
    ));
  }

  _buildRecentlyAdded(Listing listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: DashboardItem(
          listing: listing,
          userProfile: widget.userProfile,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
          onPressed: () => _promoteAdConfirmDialog(30, listing),
          onDelete: () => _buildDeleteConfirmDialog(listing),
        ),
      ),
    );
  }

  _showRecentlyAdded() {
    return StreamBuilder<QuerySnapshot>(
      stream: listingsRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Listings')
          .orderBy('timestamp', descending: true)
          .where("show", isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        try {
          if (snapshot.data!.docs.isEmpty) {
            return Container();
          }
        } catch (e) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recently Added",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.darker,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      _buildNavigateToExplorePage("Recently Added");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 5, left: 15),
              child: Row(
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Listing listing = Listing.fromDoc(document);

                      return _buildRecentlyAdded(listing);
                    })
                    .toList()
                    .cast(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _buildAllListings(Listing listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: DashboardItem(
          userProfile: widget.userProfile,
          listing: listing,
          width: double.infinity,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
          onPressed: () => _promoteAdConfirmDialog(30, listing),
          onDelete: () => _buildDeleteConfirmDialog(listing),
        ),
      ),
    );
  }

  _promoteAdConfirmDialog(int amount, Listing listing) {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.info,
      title: "Your account is to be credited \$$amount.",
      desc: "Do you wish to continue",
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
            Navigator.pop(context);
            listing.featured = true;
            DatabaseServices.updateListing(listing);
          },
          color: AppColor.green_700,
          child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _buildDeleteConfirmDialog(Listing listing) {
    return Alert(
      closeIcon: Container(),
      context: context,
      type: AlertType.error,
      title: "Delete",
      desc:
          "Are you sure you want to delete this property listing?\nThis action can't be undone.",
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
            DatabaseServices.deleteListing(listing);
            Navigator.pop(context);
            Toast.show("Listing deleted successfully",
                duration: Toast.lengthLong,
                gravity: Toast.bottom,
                backgroundColor: AppColor.green_700);
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

  _loadingWidget() {
    return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Properties",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: CircularProgressIndicator(),
          ),
        ]);
  }

  _showPopulars() {
    return StreamBuilder<QuerySnapshot>(
      stream: listingsRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Listings')
          .orderBy('likes', descending: true)
          .where("likes", isGreaterThan: 0)
          .where("show", isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        try {
          if (snapshot.data!.docs.isEmpty) {
            return Container();
          }
        } catch (e) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Most Liked",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.darker,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      _buildNavigateToExplorePage("Popular");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 5, left: 15),
              child: Row(
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document1) {
                      Listing listing = Listing.fromDoc(document1);

                      return _buildRecentlyAdded(listing);
                    })
                    .toList()
                    .cast(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _showFeatured() {
    return StreamBuilder<QuerySnapshot>(
      stream: listingsRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Listings')
          .orderBy('timestamp', descending: true)
          .where("featured", isEqualTo: true)
          .where("show", isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        try {
          if (snapshot.data!.docs.isEmpty) {
            return Container();
          }
        } catch (e) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.darker,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      _buildNavigateToExplorePage("Featured");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 5, left: 15),
              child: Row(
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Listing listing = Listing.fromDoc(document);

                      return _buildRecentlyAdded(listing);
                    })
                    .toList()
                    .cast(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _showListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: listingsRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Listings')
          .where("show", isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (!snapshot.hasData) {
          return _loadingWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }

        try {
          if (snapshot.data!.docs.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No properties yet.'),
            );
          }
        } catch (e) {
          return Container();
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Properties",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                    Listing listing = Listing.fromDoc(document);

                    return _buildAllListings(listing);
                  })
                  .toList()
                  .cast(),
            ),
          ],
        );
      },
    );
  }

  _showFilteredListings(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .where("propertyType", isEqualTo: filter)
          .where("show", isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }

        if (!snapshot.hasData) {
          return _loadingWidget();
        }

        try {
          if (snapshot.data!.docs.isEmpty) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Matched Properties",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    bottom: 200,
                    top: 50,
                  ),
                  child: const Text('No matched properties.'),
                ),
              ],
            );
          }
        } catch (e) {
          return Container();
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Matched Properties",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                    Listing listing = Listing.fromDoc(document);

                    return _buildAllListings(listing);
                  })
                  .toList()
                  .cast(),
            ),
          ],
        );
      },
    );
  }

  _setListings(String type) async {
    switch (type) {
      case "All":
        _current = _showListings();
        return _current;
      default:
        _current = _showFilteredListings(type);
        return _current;
    }
  }

  _setupData() async {
    _setListings("All");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _setupData();
  }
}
