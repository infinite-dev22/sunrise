import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/property.dart';
import '../services/database_services.dart';
import '../theme/color.dart';
import '../utilities/global_values.dart';
import 'custom_image.dart';
import 'icon_box.dart';

class FavouriteItem extends StatefulWidget {
  const FavouriteItem(
      {super.key,
      required this.data,
      this.favorite,
      required this.index,
      this.onTap});

  final Listing data;
  final Favorite? favorite;
  final int index;
  final GestureTapCallback? onTap;

  @override
  State<FavouriteItem> createState() => _FavouriteItemState();
}

class _FavouriteItemState extends State<FavouriteItem> {
  late IconData _favoriteIcon = Icons.favorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.index % 2 == 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: CustomImage(
                      widget.data.images[0],
                      width: 120,
                      height: 100,
                      radius: 15,
                    ),
                  ),
                Expanded(
                  child: Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: .1,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _buildInfo(),
                        ),
                        // const SizedBox(
                        //   width: 23,
                        // ),
                        const Spacer(),
                        _buildFavorite(),
                      ],
                    ),
                  ),
                ),
                if (widget.index % 2 != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: CustomImage(
                      widget.data.images[0],
                      width: 120,
                      height: 100,
                      radius: 15,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorite() {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          child: IconButton(
            onPressed: () {
              (widget.favorite != null)
                  ? {
                      DatabaseServices.unlikeListing(
                          getAuthUser()!.uid, widget.data, widget.favorite!.id),
                      setState(() {
                        _favoriteIcon = Icons.favorite_border;
                      })
                    }
                  : {
                      DatabaseServices.likeListing(
                          getAuthUser()!.uid, widget.data),
                      setState(() {
                        _favoriteIcon = Icons.favorite;
                      })
                    };
            },
            icon: IconBox(
              bgColor: AppColor.blue,
              child: Icon(
                _favoriteIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * .52,
          child: Text(
          widget.data.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),),
        const SizedBox(
          height: 2.5,
        ),
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              color: AppColor.darker,
              size: 16,
            ),
            const SizedBox(
              width: 3,
            ),
            Text(
              widget.data.location,
              style: const TextStyle(fontSize: 14, color: AppColor.darker),
            ),
          ],
        ),
        const SizedBox(
          height: 2.5,
        ),
        Text(
          "${widget.data.currency}${widget.data.price}",
          style: const TextStyle(
            fontSize: 16,
            color: AppColor.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
