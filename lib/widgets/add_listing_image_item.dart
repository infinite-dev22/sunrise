import 'package:flutter/material.dart';

import '../theme/color.dart';

class AddListingImageItem extends StatelessWidget {
  const AddListingImageItem(
      {super.key,
        this.height = 100,
        this.width = 100,
        this.radius = 20,
        this.bgColor,
        this.onTap, this.size = 50});
  final GestureTapCallback? onTap;
  final double height;
  final double width;
  final Color? bgColor;
  final double radius;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Icon(Icons.add_a_photo_rounded, size: size,),
      ),
    );
  }
}
