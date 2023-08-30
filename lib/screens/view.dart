import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:popup_banner/popup_banner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sunrise/models/property.dart';

import '../models/account.dart';
import '../models/activity.dart';
import '../services/database_services.dart';
import '../theme/color.dart';
import '../utilities/global_values.dart';
import '../widgets/contact_item.dart';
import '../widgets/custom_image.dart';
import '../widgets/icon_box.dart';
import '../widgets/utility_item.dart';
import 'chat.dart';

class ViewPage extends StatefulWidget {
  const ViewPage(
      {super.key, required this.listing, required this.user, this.favorite});

  final Listing listing;
  final UserProfile user;
  final Favorite? favorite;

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  late IconData _favoriteIcon =
      widget.favorite != null ? Icons.favorite : Icons.favorite_border;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var imageHeight = screenHeight * 0.5;

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
            top: 20,
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
      bgColor: AppColor.red,
      onTap: () {
        setState(() {
          (widget.favorite != null)
              ? {
                  DatabaseServices.unlikeListing(
                      getAuthUser()!.uid, widget.listing, widget.favorite!.id),
                  _favoriteIcon = Icons.favorite_border
                }
              : {
                  DatabaseServices.likeListing(
                      getAuthUser()!.uid, widget.listing),
                  _favoriteIcon = Icons.favorite
                };
        });
      },
      child: Icon(
        _favoriteIcon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildProperties() {
    List<Widget> lists = List.generate(
      widget.listing.features.length,
      (index) => UtilityItem(
        data: widget.listing.features[index],
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
          color: Colors.white,
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

  Widget _buildBlockerContact() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ContactItem(
        onCallTap: () async {
          try {
            await FlutterPhoneDirectCaller.callNumber(widget.user.phoneNumber);
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        },
        onMessageTap: () {
          _handlePressed(widget.user, context);
        },
        user: widget.user,
      ),
    );
  }

  void _handlePressed(UserProfile userProfile, BuildContext context) async {
    final navigator = Navigator.of(context);

    types.User user = types.User(
      firstName: userProfile.name,
      id: userProfile.userId, // UID from Firebase Authentication
      imageUrl: userProfile.profilePicture,
      lastName: '',
    );

    await FirebaseChatCore.instance.createUserInFirestore(user);

    final room = await FirebaseChatCore.instance.createRoom(user, metadata: {
      'imageUrl': userProfile.profilePicture,
      'name': userProfile.name
    });

    await navigator.push(
      CupertinoPageRoute(
        builder: (context) => ChatPage(
          room: room,
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
                  Text(
                    widget.listing.name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColor.darker,
                      fontWeight: FontWeight.w700,
                    ),
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
                  )
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
        user != null
            ? widget.user.userId == user!.uid
                ? _buildListingDelete()
                : _buildBlockerContact()
            : _buildBlockerContact(),
        const SizedBox(
          height: 100,
        ),
      ],
    );
  }

  _buildListingDelete() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => AppColor.red_700)),
            onPressed: () {
              _buildDeleteConfirmDialog();
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                fontSize: 20,
                color: AppColor.appBgColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildDeleteConfirmDialog() {
    return Alert(
      context: context,
      type: AlertType.error,
      title: "Delete",
      desc:
          "Are you sure you want to delete this property listing?\nThis action can't be undone.",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: AppColor.red_700,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            DatabaseServices.deleteListing(widget.listing);
            _deleteSuccessDialog();
          },
          color: AppColor.green_700,
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _deleteSuccessDialog() {
    return Alert(
      context: context,
      type: AlertType.success,
      title: "Success",
      desc: "Property listing has successfully been deleted.",
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          color: AppColor.green_700,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _buildImagesList() {
    List<String> lists = List.generate(
        widget.listing.images.length, (index) => widget.listing.images[index]);

    return lists;
  }

  _featuresWithoutIcons() {
    List<Widget> lists = List.generate(
      widget.listing.features.length,
      (index) => _buildFeaturesWithoutIcons(widget.listing.features[index]),
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
    return (data["icon"] == null)
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
        : const SizedBox.shrink();
  }
}
