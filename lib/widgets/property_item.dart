import 'package:flutter/material.dart';
import 'package:sunrise/models/activity.dart';
import 'package:sunrise/services/database_services.dart';
import 'package:sunrise/theme/color.dart';
import 'package:sunrise/utilities/global_values.dart';

import '../models/property.dart';
import 'custom_image.dart';
import 'icon_box.dart';

class PropertyItem extends StatefulWidget {
  const PropertyItem(
      {super.key, required this.data, this.favorite, this.onTap});

  final Listing data;
  final Favorite? favorite;
  final GestureTapCallback? onTap;

  @override
  State<PropertyItem> createState() => _PropertyItemState();
}

class _PropertyItemState extends State<PropertyItem> {
  late IconData _favoriteIcon =
      widget.favorite != null ? Icons.favorite : Icons.favorite_border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            CustomImage(
              widget.data.images[0],
              width: double.infinity,
              height: 200,
              radius: 25,
            ),
            Positioned(
              right: 20,
              top: 180,
              child: _buildFavorite(),
            ),
            Positioned(
              left: 15,
              top: 210,
              child: _buildInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorite() {
    return IconBox(
      onTap: () {
        (widget.favorite != null)
            ? {
                DatabaseServices.unlikeListing(
                    getAuthUser()!.uid, widget.data, widget.favorite!.id),
                setState(() {
                  _favoriteIcon = Icons.favorite_border;
                })
              }
            : {
                DatabaseServices.likeListing(getAuthUser()!.uid, widget.data),
                setState(() {
                  _favoriteIcon = Icons.favorite;
                })
              };
      },
      bgColor: AppColor.red,
      child: Icon(
        _favoriteIcon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              color: AppColor.darker,
              size: 13,
            ),
            const SizedBox(
              width: 3,
            ),
            Text(
              widget.data.location,
              style: const TextStyle(fontSize: 13, color: AppColor.darker),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "${widget.data.currency}${widget.data.price}",
          style: const TextStyle(
            fontSize: 15,
            color: AppColor.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
