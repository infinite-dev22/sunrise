import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/search.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';

import '../constants/constants.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/listing_item.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key, required this.showingContent}) : super(key: key);

  final String showingContent;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: _buildHeader(),
      body: _buildBody(),
    );
  }

  _buildHeader() {
    return AppBar(
      backgroundColor: AppColor.appBgColor,
      title: Row(
        children: [
          Expanded(
            child: Text(
              "${widget.showingContent} properties",
              style: const TextStyle(
                fontSize: 18,
                color: AppColor.darker,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
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

  _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          _setListings(widget.showingContent),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _showPopulars() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: listingsRef
          .stream(primaryKey: ['id'])
          .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
          // .gt("likes", 0)
          // .eq("show", true)
          .order('likes', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!
              .where((item) => item['show'] == true)
              .where((item) => item['likes'] > 0)
              .map((var document) {
                Listing listing = Listing.fromDoc(document);

                return _buildAllListings(listing);
              })
              .toList()
              .cast(),
        );
      },
    );
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

  _buildNavigateToViewPage(Listing listing) {
    var nav = Navigator.of(context);
    if (FirebaseAuth.instance.currentUser != null) {
      DatabaseServices.addRecent(
          FirebaseAuth.instance.currentUser!.uid, listing);
    }

    return nav.push(CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
              listing: listing,
            )));
  }

  _buildNavigateToSearchPage() async {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const SearchPage(),
    ));
  }

  _showFeatured() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: listingsRef
          .stream(primaryKey: ['id'])
          .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
          // .eq("featured", true)
          // .eq("show", true)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!
              .where((item) => item['show'] == true)
              .where((item) => item['featured'] == true)
              .map((var document) {
                Listing listing = Listing.fromDoc(document);

                return _buildAllListings(listing);
              })
              .toList()
              .cast(),
        );
      },
    );
  }

  _showRecentlyAdded() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: listingsRef
          .stream(primaryKey: ['id'])
          .eq('user_id', FirebaseAuth.instance.currentUser!.uid)
          // .eq("show", true)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!
              .where((item) => item['show'] == true)
              .map((var document) {
                Listing listing = Listing.fromDoc(document);

                return _buildAllListings(listing);
              })
              .toList()
              .cast(),
        );
      },
    );
  }

  _setListings(String type) {
    switch (type) {
      case "Popular":
        return _showPopulars();
      case "Featured":
        return _showFeatured();
      case "Recently Added":
        return _showRecentlyAdded();
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
