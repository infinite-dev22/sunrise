import 'package:flutter/material.dart';
import 'package:sunrise/theme/color.dart';

import '../models/property.dart';
import 'custom_image.dart';

class PropertyItem extends StatefulWidget {
  const PropertyItem({super.key, required this.data, this.onTap});

  final Listing data;
  final GestureTapCallback? onTap;

  @override
  State<PropertyItem> createState() => _PropertyItemState();
}

class _PropertyItemState extends State<PropertyItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        decoration: BoxDecoration(
          color: AppColor.appBgColor,
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
              left: 15,
              top: 210,
              child: _buildInfo(),
            ),
          ],
        ),
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
