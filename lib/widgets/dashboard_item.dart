import 'package:flutter/material.dart';
import 'package:sunrise/models/account.dart';
import 'package:sunrise/screens/add_listing.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/widgets/wide_button.dart';

import '../models/property.dart';
import 'custom_image.dart';

class DashboardItem extends StatelessWidget {
  const DashboardItem({
    Key? key,
    required this.listing,
    required this.userProfile,
    this.width = 280,
    this.onTap,
    this.onPressed,
    this.onDelete,
  }) : super(key: key);

  final Listing listing;
  final UserProfile userProfile;
  final double width;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            CustomImage(
              listing.images[0],
              radius: 20,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: _buildInfo(),
            ),
            const Spacer(),
            _buildMenu(context),
          ],
        ),
      ),
    );
  }

  _buildMenu(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem<int>(
                value: 0,
                child: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddListingPage(
                        listing: listing, userProfile: userProfile),
                  ));
                }),
            PopupMenuItem<int>(
                value: 1,
                enabled: !listing.featured,
                onTap: () {
                  _buildAddFeaturedDialog(context);
                },
                child: const Text('Promote')),
            PopupMenuItem<int>(
              value: 2,
              onTap: onDelete,
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColor.red_700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _buildAddFeaturedDialog(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          WideButton(
            "Promote Ad \$30/month",
            color: Colors.white,
            bgColor: AppColor.green_700,
            onPressed: onPressed,
          ),
          const SizedBox(height: 20),
          WideButton(
            "Promote Ad \$10/week",
            color: Colors.white,
            bgColor: AppColor.green_500,
            onPressed: onPressed,
          ),
          const SizedBox(
            height: 20,
          ),
          WideButton(
            "Cancel",
            color: AppColor.darker,
            bgColor: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.place_outlined,
              size: 13,
            ),
            const SizedBox(
              width: 3,
            ),
            Expanded(
              child: Text(
                listing.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "${listing.currency}${listing.price}",
          style: const TextStyle(
            fontSize: 13,
            color: AppColor.primary,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}
