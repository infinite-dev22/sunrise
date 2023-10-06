import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sunrise/screens/admin.dart';
import 'package:sunrise/theme/color.dart';

import '../models/account.dart';
import 'custom_image.dart';

class ContactItem extends StatelessWidget {
  const ContactItem(
      {Key? key,
      required this.onCallTap,
      required this.onMessageTap,
      required this.userProfile,
      required this.userType,
      this.contact = true})
      : super(key: key);

  final GestureTapCallback? onCallTap, onMessageTap;
  final UserProfile userProfile;
  final String userType;
  final bool contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.appBgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            spreadRadius: .5,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfile(),
          const SizedBox(
            height: 10,
          ),
          contact ? _buildContactPane() : _buildListingManage(context),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Row(
      children: [
        CustomImage(
          userProfile.profilePicture,
          width: 50,
          height: 50,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FirebaseAuth.instance.currentUser != null
                    ? userProfile.id == FirebaseAuth.instance.currentUser!.uid
                        ? "${userProfile.name} (You)"
                        : userProfile.name
                    : userProfile.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                userType,
                style: const TextStyle(fontSize: 13, color: AppColor.darker),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactPane() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: onMessageTap,
          child: const Row(
            children: [
              Icon(Icons.message, color: AppColor.darker),
              SizedBox(
                width: 10,
              ),
              Text("Message",
                  style: TextStyle(fontSize: 13, color: AppColor.darker)),
            ],
          ),
        ),
        const Spacer(),
        if (userProfile.phoneNumber.isNotEmpty)
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColor.green_700),
            onPressed: onCallTap,
            child: const Row(
              children: [
                Icon(Icons.call, color: AppColor.appBgColor),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Call",
                  style: TextStyle(fontSize: 13, color: AppColor.appBgColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _buildListingManage(BuildContext context) {
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
                    (states) => AppColor.blue_500)),
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => AdminApp(userProfile: userProfile),
              ));
            },
            child: const Text(
              "Manage Ad",
              style: TextStyle(
                fontSize: 18,
                color: AppColor.darker,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
