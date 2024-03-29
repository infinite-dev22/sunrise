import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:sunrise/screens/view.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/custom_textbox.dart';

import '../models/property.dart';
import '../services/database_services.dart';
import '../widgets/listing_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _searched = [];
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
      backgroundColor: AppColor.appBgColor,
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
              onChanged: _onListingsSearched,
            ),
          ),
        ],
      ),
    );
  }

  _buildBody() {
    return _searched.isEmpty && searchController.text.isNotEmpty
        ? Center(
            child: Text('No result found for "${searchController.text}"'),
          )
        : _showSearchedListings(searchController.text.trim());
  }

  _onListingsSearched(String filter) async {
    _searched = await DatabaseServices.getListingsBySearch(filter);
    setState(() {});
  }

  _showSearchedListings(String filter) {
    return ListView.builder(
      itemCount: _searched.length,
      itemBuilder: (context, index) {
        return _buildAllListings(_searched[index]);
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

  _buildNavigateToViewPage(Listing listing) async {
    var nav = Navigator.of(context);
    if (FirebaseAuth.instance.currentUser != null) {
      DatabaseServices.addRecent(
          FirebaseAuth.instance.currentUser!.uid, listing);
    }

    return nav.push(
      CupertinoPageRoute(
        builder: (BuildContext context) => ViewPage(
          listing: listing,
        ),
      ),
    );
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
                const Spacer(),
                Text(
                  isListen ? "Say something" : "Tap the mic to listen",
                  style: const TextStyle(fontSize: 18),
                ),
                const Text(
                  "English",
                  style: TextStyle(fontSize: 13),
                ),
                const Spacer(),
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
    _initSpeech();
  }
}
