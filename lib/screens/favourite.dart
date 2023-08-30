import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';

import '../constants/constants.dart';
import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../theme/color.dart';
import '../utilities/global_values.dart';
import '../widgets/favourite_item.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
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
    return Row(
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
          _showFavorites(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _buildNavigateToViewPage(var data, favorite) async {
    var nav = Navigator.of(context);
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(data.userId);

    return nav.push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: data,
              user: brokerProfile,
              favorite: favorite,
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
            _buildNavigateToViewPage(listing, favorite);
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
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection("favorites")
          .doc(user!.uid)
          .collection('Favorites')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Center(
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
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('Your favorites appear here'),
            );
          }
        } catch (e) {
          return Container();
        }

        return Column(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
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
        stream: db
            .collectionGroup('Listings')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Inner error");
          }

          try {
            if (snapshot.data!.docs.isEmpty) {
              return Container();
            }
          } catch (e) {
            return Container();
          }

          return Column(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Listing listing = Listing.fromDoc(document);

                  if (listing.id == favorite.listingId) {
                    return _buildFavourites(listing, index, favorite);
                  }

                  return const SizedBox.shrink();
                })
                .toList()
                .cast(),
          );
        });
  }
}
