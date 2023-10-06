import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';

import '../constants/constants.dart';
import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';
import '../theme/color.dart';
import '../widgets/favourite_item.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key, this.userProfile});

  final UserProfile? userProfile;

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  late final Stream<List<Map<String, dynamic>>> _favoritesStream;
  late final Stream<List<Map<String, dynamic>>> _listingsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.appBgColor,
      title: Row(
        children: [
          const Expanded(
            child: Text(
              "Favorite properties",
              style: TextStyle(
                fontSize: 18,
                color: AppColor.darker,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              child: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              onTap: () {
                _buildNavigateToSearchPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildNavigateToSearchPage() async {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const SearchPage(),
    ));
  }

  _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          if (widget.userProfile != null) _showFavorites(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _buildNavigateToViewPage(var data) async {
    return Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: data,
            )));
  }

  _buildFavourites(Listing listing, index, favorite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: FavouriteItem(
          data: listing,
          onTap: () {
            _buildNavigateToViewPage(listing);
          },
          index: index,
          favorite: favorite,
        ),
      ),
    );
  }

  _loadingWidget() {
    return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 30),
          Center(
            child: CircularProgressIndicator(),
          ),
        ]);
  }

  _showFavorites() {
    int index = -1;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _favoritesStream,
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }

        if (!snapshot.hasData) {
          return _loadingWidget();
        }

        try {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your favorites appear here'),
                ],
              ),
            );
          }
        } catch (e) {
          return Container();
        }

        return Column(
          children: snapshot.data!
              .map((var document) {
                Favorite favorite = Favorite.fromDoc(document);

                index++;

                return _getListings(favorite, index);
              })
              .toList()
              .cast(),
        );
      },
    );
  }

  _getListings(Favorite favorite, int index) {
    return StreamBuilder(
        stream: _listingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Inner error");
          }

          try {
            if (snapshot.data!.isEmpty) {
              return Container();
            }
          } catch (e) {
            return Container();
          }

          return Column(
            children: snapshot.data!
                .map((var document) {
                  Listing listing = Listing.fromDoc(document);

                  if (listing.id == favorite.listingId) {
                    return _buildFavourites(listing, index, favorite);
                  }

                  return Container();
                })
                .toList()
                .cast(),
          );
        });
  }

  initStream() {
    if (FirebaseAuth.instance.currentUser != null) {
      _favoritesStream = favoritesRef
          .stream(primaryKey: ['id'])
          .eq('user_id', widget.userProfile!.userId)
          .order('created_at', ascending: false)
          .execute();
    }

    _listingsStream = listingsRef
        .stream(primaryKey: ['id'])
        .eq("show", true)
        .order('created_at', ascending: false)
        .execute();
  }

  @override
  void initState() {
    initStream();

    // TODO: implement initState
    super.initState();
  }
}
