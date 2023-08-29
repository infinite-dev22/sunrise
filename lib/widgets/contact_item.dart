import 'package:flutter/material.dart';
import 'package:sunrise/theme/color.dart';

import '../models/account.dart';
import 'custom_image.dart';

class ContactItem extends StatelessWidget {
  const ContactItem(
      {Key? key,
      required this.onCallTap,
      required this.onMessageTap,
      required this.user})
      : super(key: key);

  final GestureTapCallback? onCallTap, onMessageTap;
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
          _buildContactPane(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Row(
      children: [
        CustomImage(
          user.profilePicture,
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
                user.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "broker",
                style: TextStyle(fontSize: 13, color: AppColor.darker),
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
        if (user.phoneNumber.isNotEmpty)
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
}
