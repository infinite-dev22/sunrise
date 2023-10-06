import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:popup_banner/popup_banner.dart';
import 'package:sunrise/models/property.dart';
import 'package:sunrise/screens/welcome.dart';
import 'package:toast/toast.dart';

import '../models/account.dart';
import '../models/activity.dart';
import '../services/database_services.dart';
import '../theme/color.dart';
import '../utilities/features/chat/chat_core.dart';
import '../widgets/contact_item.dart';
import '../widgets/custom_image.dart';
import '../widgets/icon_box.dart';
import '../widgets/utility_item.dart';
import 'chat.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key, required this.listing});

  final Listing listing;

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  ToastContext toast = ToastContext();

  late List _favorites;
  Favorite? _favorite;
  bool isFavorite = false;

  // IconData _favoriteIcon = Icons.favorite_border;
  IconData _favoriteIcon = Icons.favorite_border;
  late UserProfile? _brokerProfile;

  @override
  Widget build(BuildContext context) {
    toast.init(context);

    var screenHeight = MediaQuery.of(context).size.height;
    var imageHeight = screenHeight * 0.5;

    if (FirebaseAuth.instance.currentUser != null) {
      DatabaseServices.addRecent(
          FirebaseAuth.instance.currentUser!.uid, widget.listing);
      _getFavorite();
    }

    try {
      return Scaffold(
          backgroundColor: AppColor.appBgColor,
          body: Stack(
            children: [
              Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return CustomImage(
                    widget.listing.images[index],
                    radius: 0,
                    width: double.infinity,
                    height: imageHeight,
                    bgColor: AppColor.darker,
                    onTap: () {
                      PopupBanner(
                        context: context,
                        images: _buildImagesList(),
                        onClick: (index) {
                          debugPrint("CLICKED $index");
                        },
                        autoSlide: false,
                        fromNetwork: true,
                        fit: BoxFit.contain,
                        dotsAlignment: Alignment.bottomCenter,
                      ).show();
                    },
                  );
                },
                itemCount: widget.listing.images.length,
                loop: false,
              ),
              Positioned(
                top: 25,
                left: 5,
                child: IconBox(
                  onTap: () => Navigator.pop(context),
                  bgColor: AppColor.translucent,
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Positioned(
                right: 10,
                top: imageHeight * .82,
                child: _buildFavorite(),
              ),
              Container(
                margin: EdgeInsets.only(top: screenHeight * .48),
                child: _buildInfo(),
              ),
            ],
          ));
    } catch (e) {
      return _buildProgress();
    }
  }

  _buildProgress() {
    return Container(
      color: AppColor.appBgColor,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.appBgColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      decoration: const BoxDecoration(
        color: AppColor.appBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildPropertyDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorite() {
    return IconBox(
      radius: 10,
      bgColor: AppColor.primary,
      onTap: () {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            Toast.show("Sign in to continue",
                duration: Toast.lengthLong, gravity: Toast.bottom);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
                ));
          } else {
            setState(() {
              if (isFavorite) {
                if (_favorite != null) {
                  DatabaseServices.unlikeListing(
                      user.uid, widget.listing, _favorite!.id);
                  _favoriteIcon = Icons.favorite_border;
                  isFavorite = false;
                }
              } else {
                DatabaseServices.likeListing(user.uid, widget.listing);
                _favoriteIcon = Icons.favorite;
                isFavorite = true;
              }
            });
          }
        });
      },
      child: Icon(
        _favoriteIcon,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  Widget _buildProperties() {
    List<Widget> lists = List.generate(
      widget.listing.features.length,
      (index) => UtilityItem(
        data: jsonDecode(widget.listing.features[index]),
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 10),
      scrollDirection: Axis.horizontal,
      child: Row(children: lists),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          color: Color.fromRGBO(227, 204, 168, .2),
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                color: AppColor.darker,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              widget.listing.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColor.darker,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerContact({bool contact = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ContactItem(
        contact: contact,
        onCallTap: () async {
          if (FirebaseAuth.instance.currentUser == null) {
            Toast.show("Sign in to continue",
                duration: Toast.lengthLong, gravity: Toast.bottom);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
                ));
          } else {
            try {
              await FlutterPhoneDirectCaller.callNumber(
                  _brokerProfile!.phoneNumber);
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          }
        },
        onMessageTap: () {
          if (FirebaseAuth.instance.currentUser == null) {
            Toast.show("Sign in to continue",
                duration: Toast.lengthLong, gravity: Toast.bottom);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
                ));
          } else {
            _handlePressed(_brokerProfile!, context);
          }
        },
        userProfile: _brokerProfile!,
        userType: widget.listing.isPropertyOwner,
      ),
    );
  }

  void _handlePressed(UserProfile userProfile, BuildContext context) async {
    final navigator = Navigator.of(context);

    final room = await SupabaseChatCore.instance
        .createRoom(userProfile, widget.listing.id!, widget.listing.name);

    await navigator.push(
      CupertinoPageRoute(
        builder: (context) => ChatPage(
          room: room!,
          userProfile: _brokerProfile,
        ),
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.listing.name,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColor.darker,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // ),
                  ),
                  const Spacer(),
                  Text(
                    "${widget.listing.currency}${widget.listing.price}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColor.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: 16,
                  ),
                  Text(
                    widget.listing.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (widget.listing.yearConstructed.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          color: Colors.grey,
                          size: 16,
                        ),
                        Text(
                          "Constructed: ${widget.listing.yearConstructed}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.sparkles,
                          color: Colors.grey,
                          size: 16,
                        ),
                        Text(
                          widget.listing.propertyType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.sparkles,
                    color: Colors.grey,
                    size: 16,
                  ),
                  Text(
                    widget.listing.status,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (widget.listing.yearConstructed.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.sparkles,
                          color: Colors.grey,
                          size: 16,
                        ),
                        Text(
                          widget.listing.propertyType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        _buildProperties(),
        const SizedBox(
          height: 20,
        ),
        _featuresWithoutIcons(),
        const SizedBox(
          height: 20,
        ),
        _buildDescription(),
        const SizedBox(
          height: 20,
        ),
        if (FirebaseAuth.instance.currentUser != null)
          if (_brokerProfile != null)
            if (_brokerProfile!.userId ==
                FirebaseAuth.instance.currentUser!.uid)
              _buildBlockerContact(contact: false)
            else
              _buildBlockerContact()
          else
            const Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColor.grey_300),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Ad owner no longer exists on this platform.',
                      style: TextStyle(color: AppColor.grey_300),
                    ),
                  ],
                )
              ],
            )
        else
          _buildBlockerContact(),
        const SizedBox(
          height: 100,
        ),
      ],
    );
  }

  _buildImagesList() {
    List<String> lists = List.generate(
        widget.listing.images.length, (index) => widget.listing.images[index]);

    return lists;
  }

  _featuresWithoutIcons() {
    List<Widget> lists = List.generate(
      widget.listing.features.length,
      (index) => _buildFeaturesWithoutIcons(
          jsonDecode(widget.listing.features[index])),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: lists,
          ),
        ],
      ),
    );
  }

  _buildFeaturesWithoutIcons(data) {
    return (data["icon"] == null || data["icon"] == "")
        ? (data["value"] == true)
            ? Row(
                children: [
                  const Checkbox(value: true, onChanged: null),
                  Text(
                    data["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              )
            : const SizedBox.shrink()
        : const SizedBox.shrink();
  }

  _getFavorite() async {
    try {
      _favorites = await DatabaseServices.getFavorite(widget.listing.id!);
    } catch (e) {
      if (e
          .toString()
          .contains('Connection closed before full header was received')) {
        Toast.show("Your connection is unstable",
            duration: Toast.lengthLong,
            gravity: Toast.top,
            backgroundColor: AppColor.darker);
      }
      return;
    }

    if (_favorites.isNotEmpty) {
      _favorite = _favorites[0];
      _favoriteIcon = Icons.favorite;
    }
  }

  _setUpData() async {
    UserProfile? brokerProfile =
        await DatabaseServices.getUserProfile(widget.listing.userId);
    // UserProfile currentUserProfile =
    //     await DatabaseServices.getUserProfile(widget.listing.userId);

    setState(() {
      _brokerProfile = brokerProfile;
    });
  }

  @override
  void initState() {
    _setUpData();

    super.initState();
  }
}
