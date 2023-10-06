import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';

import '../theme/color.dart';
import 'custom_image.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile? userProfile;

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
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final hasImage = userProfile?.profilePicture != null;
    final name = userProfile?.name ?? '';

    return Row(
      children: [
        CustomImage(
          hasImage
              ? userProfile!.profilePicture
              : Text(
                  name.isEmpty ? '' : name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
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
              Row(
                children: [
                  Text(
                    userProfile!.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Text(
                    "1 min",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(
                height: 1,
              ),
              const Text(
                "Test",
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
}
