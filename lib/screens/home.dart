import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/models/activity.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/data.dart';
import 'package:sunrise/utilities/global_values.dart';
import 'package:sunrise/widgets/category_item.dart';
import 'package:sunrise/widgets/custom_image.dart';
import 'package:sunrise/widgets/custom_textbox.dart';
import 'package:sunrise/widgets/property_item.dart';
import 'package:sunrise/widgets/recent_item.dart';
import 'package:sunrise/widgets/recommend_item.dart';

import '../constants/constants.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/listing_item.dart';
import 'explore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _favorites = [];
  var _current;
  bool _noData = false;
  int _selectedCategory = 0;
  late UserProfile _brokerProfile;

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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextBox(
                hint: "Search properties",
                prefix: const Icon(Icons.search, color: Colors.grey),
                suffix: const Icon(Icons.mic, color: Colors.grey),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _setListings(value);
                    } else {
                      _setListings("All");
                    }
                  });
                },
                readOnly: true,
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
            ),
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
          (!_noData) ? _buildCategories() : Container(),
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

  _buildNavigateToViewPage(Listing listing, favorite) async {
    var nav = Navigator.of(context);
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(listing.userId);

    DatabaseServices.addRecent(user!.uid, listing);

    return nav.push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: listing,
              user: brokerProfile,
              favorite: favorite,
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

  _buildPopulars(Listing listing, Favorite? favorite) {
    return PropertyItem(
      data: listing,
      favorite: favorite,
      onTap: () {
        _buildNavigateToViewPage(listing, favorite);
      },
    );
  }

  _buildRecommended(Listing listing, favorite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: RecommendItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing, favorite);
          },
        ),
      ),
    );
  }

  _buildRecent(Listing listing, favorite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: RecentItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing, favorite);
          },
        ),
      ),
    );
  }

  _showRecents() {
    Favorite? favorite;
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection("recents")
          .doc(user!.uid)
          .collection('Recents')
          .limit(10)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    _showFeatured();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
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
                    "Recent",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColor.darker,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        DatabaseServices.deleteUserRecents();
                      }),
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

                      return _getListingsRealtime(recentlyViewed, favorite);
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

  _getListingsRealtime(RecentlyViewed recentlyViewed, Favorite? favorite) {
    return StreamBuilder(
        stream: db
            .collectionGroup('Listings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Inner error");
          }

          if (snapshot.data!.docs.isEmpty) {
            return Container();
          }

          return Row(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Listing listing = Listing.fromDoc(document);

                  if (recentlyViewed.listingId == listing.id) {
                    // for (Favorite fav in _favorites) {
                    //   if (fav.listingId == listing.id) {
                    //     favorite = fav;
                    //     return _buildRecent(
                    //         listing, favorite);
                    //   } else {
                    //     favorite = null;
                    //     return _buildRecent(
                    //         listing, favorite);
                    //   }
                    // }
                    return _buildRecent(listing, favorite);
                  }

                  return const SizedBox.shrink();
                })
                .toList()
                .cast(),
          );
        });
  }

  _buildAllListings(Listing listing, favorite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 15),
        child: ListingItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing, favorite);
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

  _showPopulars() {
    var popularItemWidgets = [];

    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .limit(10)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    _showPopulars();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
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

                    db
                        .collection("favorites")
                        .doc(user!.uid)
                        .collection('Favorites')
                        .orderBy('timestamp', descending: true)
                        .snapshots()
                        .listen((snapshot2) {
                      popularItemWidgets.addAll(snapshot2.docs.map((document2) {
                        Favorite favorite = Favorite.fromDoc(document2);

                        if (favorite.listingId == listing.id) {
                          return _buildPopulars(listing, favorite);
                        } else {
                          return _buildPopulars(listing, null);
                        }
                      }).toList());
                    });

                    if (popularItemWidgets.isNotEmpty) {
                      for (var popularItem in popularItemWidgets) {
                        return popularItem;
                      }
                    } else {
                      return _buildPopulars(listing, null);
                    }
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
    Favorite? favorite;
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .orderBy('timestamp', descending: true)
          .where("featured", isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                IconButton(
                  onPressed: () {
                    _showFeatured();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
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

                      for (Favorite fav in _favorites) {
                        if (fav.listingId == listing.id) {
                          favorite = fav;
                        } else {
                          favorite = null;
                        }
                      }

                      return _buildRecommended(listing, favorite);
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
    Favorite? favorite;
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Something went wrong'),
                    IconButton(
                      onPressed: () {
                        _showListings();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
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

                    for (Favorite fav in _favorites) {
                      if (fav.listingId == listing.id) {
                        favorite = fav;
                      } else {
                        favorite = null;
                      }
                    }

                    return _buildAllListings(listing, favorite);
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
    Favorite? favorite;
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .orderBy('timestamp', descending: true)
          .where("propertyType", isEqualTo: filter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Something went wrong'),
              IconButton(
                onPressed: () {
                  _showFilteredListings(filter);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }

        if (!snapshot.hasData) {
          return _loadingWidget();
        }

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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

                    for (Favorite fav in _favorites) {
                      if (fav.listingId == listing.id) {
                        favorite = fav;
                      } else {
                        favorite = null;
                      }
                    }

                    return _buildAllListings(listing, favorite);
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
    List favorites = await DatabaseServices.getFavorites();

    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setupData();
  }
}
