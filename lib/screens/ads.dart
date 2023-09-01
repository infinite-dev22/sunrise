import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';

import '../models/property.dart';
import '../services/database_services.dart';
import '../utilities/global_values.dart';
import '../widgets/listing_item.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  List _brokerListings = [];
  bool _loading = false;

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
          "Your Ads",
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
          const SizedBox(
            height: 5,
          ),
          _loading ? const LinearProgressIndicator() : const SizedBox.shrink(),
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Most Liked",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  "See all",
                  style: TextStyle(fontSize: 14, color: AppColor.darker),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: _brokerListings.isEmpty && _loading == false
                ? [
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'There are no Listings available',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  ]
                : _showBrokerListings(),
          ),
          // _buildPopulars(),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Most Viewed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  "See all",
                  style: TextStyle(fontSize: 14, color: AppColor.darker),
                ),
              ],
            ),
          ),
          // const SizedBox(
          //   height: 20,
          // ),
          // _buildRecommended(),
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recently Viewed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  "See all",
                  style: TextStyle(fontSize: 14, color: AppColor.darker),
                ),
              ],
            ),
          ),
          // const SizedBox(
          //   height: 20,
          // ),
          // _buildRecent(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  // Widget _buildPopulars() {
  //   List<Widget> lists = List.generate(
  //     populars.length,
  //     (index) => Padding(
  //       padding: const EdgeInsets.only(bottom: 10),
  //       child: ListingItem(
  //         data: populars[index],
  //         onTap: () {
  //           _buildNavigateToViewPage(populars[index]);
  //         },
  //       ),
  //     ),
  //   );
  //
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.only(bottom: 5, left: 15),
  //     child: Column(
  //       children: lists,
  //     ),
  //   );
  // }
  //
  // Widget _buildRecommended() {
  //   List<Widget> lists = List.generate(
  //     recommended.length,
  //     (index) => Padding(
  //       padding: const EdgeInsets.only(bottom: 10),
  //       child: ListingItem(
  //         data: recommended[index],
  //         onTap: () {
  //           _buildNavigateToViewPage(recommended[index]);
  //         },
  //       ),
  //     ),
  //   );
  //
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.only(bottom: 5, left: 15),
  //     child: Column(children: lists),
  //   );
  // }
  //
  // Widget _buildRecent() {
  //   List<Widget> lists = List.generate(
  //     recents.length,
  //     (index) => Padding(
  //       padding: const EdgeInsets.only(bottom: 10),
  //       child: ListingItem(
  //         data: recents[index],
  //         onTap: () {
  //           _buildNavigateToViewPage(recents[index]);
  //         },
  //       ),
  //     ),
  //   );
  //
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.only(bottom: 5, left: 15),
  //     child: Column(
  //       children: lists,
  //     ),
  //   );
  // }

  _buildNavigateToViewPage(var data) {
    return Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => ViewPage(
                  listing: data,
                  user: widget.userProfile,
                )));
  }

  _buildListings(Listing listing) {
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

  _showBrokerListings() {
    List<Widget> brokerListingsList = [];

    for (Listing listing in _brokerListings) {
      brokerListingsList.add(FutureBuilder(
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return _buildListings(listing);
        },
        future: null,
      ));
    }
    return brokerListingsList;
  }

  _setupBrokerListings() async {
    setState(() {
      _loading = true;
    });

    List brokerListings =
        await DatabaseServices.getUserListings(getAuthUser()!.uid);

    if (mounted) {
      setState(() {
        _brokerListings = brokerListings;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _setupBrokerListings();

    super.initState();
  }
}
