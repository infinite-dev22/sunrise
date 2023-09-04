import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/models/activity.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/data.dart';
import 'package:sunrise/widgets/bar_chart1.dart';
import 'package:sunrise/widgets/category_item.dart';
import 'package:sunrise/widgets/property_item.dart';
import 'package:sunrise/widgets/recent_item.dart';
import 'package:sunrise/widgets/recommend_item.dart';

import '../constants/constants.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/line_chart1.dart';
import '../widgets/line_chart2.dart';
import '../widgets/listing_item.dart';
import 'explore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Widget _current;
  bool _noData = false;
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
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
    return const Column(
      children: [
        Text(
          "Dashboard",
          style: TextStyle(
            color: AppColor.darker,
          ),
        ),
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (!_noData) ? _buildCategories() : Container(),
          _buildViewChart1(),
          const SizedBox(height: 20),
          _buildViewChart2(),
          const SizedBox(height: 20),
          _buildViewChart3(),
          _showPopulars(),
          _showFeatured(),
          _showRecents(),
          _current,
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    List<Widget> lists = List.generate(
      categories.length,
      (index) => CategoryItem(
        data: categories[index],
        selected: index == _selectedCategory,
        onTap: () {
          setState(() {
            _setListings(categories[index]["name"]);
            _selectedCategory = index;
          });
        },
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 5, left: 15),
          child: Row(children: lists),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _buildNavigateToViewPage(Listing listing) async {
    var nav = Navigator.of(context);

    // These variables below affect performance significantly, try putting them
    // into their respective screen(ViewPage).
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(listing.userId);
    List favorite = await DatabaseServices.getFavorite(listing.id);

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

  _buildPopulars(Listing listing) {
    return PropertyItem(
      data: listing,
      onTap: () {
        _buildNavigateToViewPage(listing);
      },
    );
  }

  _buildRecommended(Listing listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: RecommendItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
        ),
      ),
    );
  }

  _buildRecent(Listing listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: RecentItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
        ),
      ),
    );
  }

  _showRecents() {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection("recents")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Recents')
          .limit(10)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    build(context);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  // GestureDetector(
                  //     child: const Text(
                  //       "Clear",
                  //       style: TextStyle(
                  //           fontSize: 16,
                  //           color: AppColor.darker,
                  //           decoration: TextDecoration.underline),
                  //     ),
                  //     onTap: () {
                  //       DatabaseServices.deleteUserRecents();
                  //     }),
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
                      RecentlyViewed recentlyViewed =
                          RecentlyViewed.fromDoc(document);

                      return _getListings(recentlyViewed);
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

  _getListings(RecentlyViewed recentlyViewed) {
    return StreamBuilder(
        stream: db
            .collectionGroup('Listings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          try {
            if (snapshot.data!.docs.isEmpty) {
              if (snapshot.hasError) {
                return const Text("Inner error");
              }
            }
          } catch (e) {
            return Container();
          }

          try {
            if (snapshot.data!.docs.isEmpty) {
              return Container();
            }
          } catch (e) {
            return Container();
          }

          return Row(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Listing listing = Listing.fromDoc(document);

                  if (recentlyViewed.listingId == listing.id) {
                    return _buildRecent(listing);
                  }

                  return const SizedBox.shrink();
                })
                .toList()
                .cast(),
          );
        });
  }

  _buildAllListings(Listing listing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: ListingItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
        ),
      ),
    );
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

  _buildViewChart1() {
    return const LineChartSample1();
  }

  _buildViewChart2() {
    return const LineChartSample2();
  }

  _buildViewChart3() {
    return BarChartSample1();
  }

  _showPopulars() {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .orderBy('likes', descending: true)
          .where("likes", isGreaterThan: 0)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    build(context);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
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
                    "Popular",
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
            CarouselSlider(
              options: CarouselOptions(
                  height: 290,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: .8,
                  enableInfiniteScroll: false,
                  initialPage: 0),
              items: snapshot.data!.docs
                  .map((DocumentSnapshot document1) {
                    Listing listing = Listing.fromDoc(document1);

                    return _buildPopulars(listing);
                  })
                  .toList()
                  .cast(),
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
      stream: db
          .collectionGroup('Listings')
          .orderBy('timestamp', descending: true)
          .where("featured", isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    build(context);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
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

                      return _buildRecommended(listing);
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
      stream: db
          .collectionGroup('Listings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    build(context);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
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
            _noData = true;
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

        _noData = false;

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
          .orderBy('timestamp', descending: true)
          .where("propertyType", isEqualTo: filter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    build(context);
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
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
