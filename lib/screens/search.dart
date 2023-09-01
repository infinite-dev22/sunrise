import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/custom_textbox.dart';

import '../constants/constants.dart';
import '../models/account.dart';
import '../models/activity.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../utilities/global_values.dart';
import '../widgets/listing_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _favorites = [];
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  TextEditingController searchController = TextEditingController();

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      searchController.text = result.recognizedWords;
    });
  }

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
      title: Row(
        children: [
          Expanded(
            child: CustomTextBox(
              hint: "Search properties",
              controller: searchController,
              prefix: const Icon(Icons.search, color: Colors.grey),
              suffix: InkWell(
                onTap: () => _showListenDialog(),
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: const Icon(Icons.mic, color: Colors.grey),
              ),
              autoFocus: true,
              onChanged: (value) {
                setState(() {
                  searchController.text = value;
                });
              },
            ),
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
          const SizedBox(
            height: 20,
          ),
          _showSearchedListings(searchController.text.trim()),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _showSearchedListings(String filter) {
    Favorite? favorite;
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collectionGroup('Listings')
          .where("name", isGreaterThanOrEqualTo: filter)
          .orderBy('name', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Something went wrong ${snapshot.error.toString()}'),
                IconButton(
                  onPressed: () {
                    _showSearchedListings(filter);
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

        if (snapshot.data!.docs.isEmpty) {
          return searchController.text.isEmpty
              ? Container()
              : const Center(
                  child: Text("No matched properties"),
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

  _buildNavigateToViewPage(Listing listing, favorite) async {
    var nav = Navigator.of(context);
    UserProfile brokerProfile =
        await DatabaseServices.getUserProfile(listing.userId);

    DatabaseServices.addRecent(user!.uid, listing);

    return nav.push(
      CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
          listing: listing,
          user: brokerProfile,
          favorite: favorite,
        ),
      ),
    );
  }

  _loadingWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 200),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  _setupData() async {
    List favorites = await DatabaseServices.getFavorites();

    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  _showListenDialog() {
    _startListening();
    bool isListen = true;

    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.only(top: 80),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                AvatarGlow(
                  animate: isListen,
                  glowColor: AppColor.primary,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  endRadius: 100.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: IconButton(
                      onPressed: () {
                        if (_speechEnabled) {
                          isListen ? _stopListening() : _startListening();
                        }

                        setState(() {
                          isListen = !isListen;
                        });
                      },
                      icon: Icon(
                        isListen ? Icons.mic : Icons.mic_off_rounded,
                        size: 60,
                        color: isListen ? AppColor.primary : AppColor.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  isListen ? "Say something" : "Tap the mic to listen",
                  style: const TextStyle(fontSize: 18),
                ),
                const Text(
                  "English",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _stopListening();
      isListen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setupData();
    _initSpeech();
  }
}
