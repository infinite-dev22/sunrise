import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/models/activity.dart';
import 'package:sunrise/screens/profile.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/screens/welcome.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/data.dart';
import 'package:sunrise/widgets/category_item.dart';
import 'package:sunrise/widgets/custom_image.dart';
import 'package:sunrise/widgets/custom_textbox.dart';
import 'package:sunrise/widgets/property_item.dart';
import 'package:sunrise/widgets/recent_item.dart';
import 'package:sunrise/widgets/recommend_item.dart';
import 'package:toast/toast.dart';

import '../constants/constants.dart';
import '../models/property.dart';
import '../widgets/listing_item.dart';
import 'explore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.userProfile}) : super(key: key);

  final UserProfile? userProfile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToastContext toast = ToastContext();

  late Widget _current;
  bool _noData = false;
  int _selectedCategory = 0;

  late Stream<List<Map<String, dynamic>>> _popularLimitStream;

  late Stream<List<Map<String, dynamic>>> _featuredLimitStream;

  late Stream<List<Map<String, dynamic>>> _recentsLimitStream;

  late Stream<List<Map<String, dynamic>>> _listingStream;

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      backgroundColor: AppColor.appBgColor,
    );
  }

  _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appBgColor,
      title: Column(
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
                  autoFocus: false,
                  readOnly: true,
                  onTap: () {
                    _buildNavigateToSearchPage();
                  },
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              widget.userProfile != null
                  ? CustomImage(
                      widget.userProfile!.profilePicture,
                      width: 35,
                      height: 35,
                      trBackground: true,
                      borderColor: AppColor.primary,
                      radius: 10,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfilePage(userProfile: widget.userProfile!),
                        ));
                      },
                    )
                  : CustomImage(
                      "assets/images/user-placeholder.png",
                      width: 35,
                      height: 35,
                      trBackground: true,
                      borderColor: AppColor.primary,
                      isNetwork: false,
                      radius: 10,
                      onTap: () {
                        Toast.show("Sign in to continue",
                            duration: Toast.lengthLong, gravity: Toast.bottom);

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => WelcomePage(),
                        ));
                      },
                    ),
            ],
          ),
        ],
      ),
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
          if (FirebaseAuth.instance.currentUser != null) _showRecents(),
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
    return Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: listing,
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _recentsLimitStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (!snapshot.error
              .toString()
              .contains('OS Error: No address associated with hostname,')) {
            Toast.show("An Error occurred",
                duration: Toast.lengthLong, gravity: Toast.bottom);
          }
        }

        try {
          if (snapshot.data!.isEmpty) {
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
                children: snapshot.data!
                    .map((doc) {
                      RecentlyViewed recentlyViewed =
                          RecentlyViewed.fromDoc(doc);

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
        stream: _listingStream,
        builder: (context, snapshot) {
          try {
            if (snapshot.data!.isEmpty) {
              if (snapshot.hasError) {
                return const Text("Inner error");
              }
            }
          } catch (e) {
            return Container();
          }

          try {
            if (snapshot.data!.isEmpty) {
              return Container();
            }
          } catch (e) {
            return Container();
          }

          return Row(
            children: snapshot.data!
                .map((var document) {
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

  _showPopulars() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _popularLimitStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        try {
          if (snapshot.data!.isEmpty) {
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
              items: snapshot.data!
                  .where((item) => item['likes'] > 0)
                  .map((doc) {
                    Listing listing = Listing.fromDoc(doc);

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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _featuredLimitStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        try {
          if (snapshot.data!.isEmpty) {
            return Container();
          }
        } catch (e) {
          return Container();
        }

        List items = snapshot.data!
            .where((item) => item['featured'] == true)
            .map((var document) {
          Listing listing = Listing.fromDoc(document);

          return _buildRecommended(listing);
        }).toList();

        if (items.isEmpty) {
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
                children: items.cast(),
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _listingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Text('Something went wrong'),
                IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    },
                    icon: const Icon(Icons.refresh_rounded))
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
          if (snapshot.data!.isEmpty) {
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
              children: snapshot.data!
                  .where((item) => item['show'] == true)
                  .map((var document) {
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _listingTypeFilteredStream(filter),
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
          if (snapshot.data!.isEmpty) {
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
              children: snapshot.data!
                  .where((item) => item['show'] == true)
                  .map((var document) {
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

  _initStreams() {
    _popularLimitStream = listingsRef
        .stream(primaryKey: ['id'])
        .eq("show", true)
        .order('likes', ascending: false)
        .limit(10);

    _featuredLimitStream = listingsRef
        .stream(primaryKey: ['id'])
        .eq("show", true)
        .order('created_at', ascending: false)
        .limit(10);

    if (FirebaseAuth.instance.currentUser != null) {
      _recentsLimitStream = recentsRef
          .stream(primaryKey: ['id'])
          .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
          .order('created_at', ascending: false)
          .limit(10);
    }

    _listingStream = listingsRef
        .stream(primaryKey: ['id'])
        .eq("show", true)
        .order('created_at', ascending: false);

    setState(() {});
  }

  _listingTypeFilteredStream(String filter) {
    return listingsRef
        .stream(primaryKey: ['id'])
        .eq("propertyType", filter)
        .order('created_at', ascending: false);
  }

  _setupData() {
    _setListings("All");
    setState(() {});
  }

  @override
  void initState() {
    _initStreams();
    _setupData();

    super.initState();
  }
}
