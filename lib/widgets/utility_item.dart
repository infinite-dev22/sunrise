import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/color.dart';

class UtilityItem extends StatelessWidget {
  const UtilityItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map data;

  @override
  Widget build(BuildContext context) {
    if (data["icon"] != null) {
      if (data["value"] != "" && data["value"] != null) {
        if (data["value"] == true) {
          return _buildFeature();
        } else {
          return const SizedBox.shrink();
        }
      } else if (data["quantity"] != "" && data["quantity"] != null) {
        return _buildFeature();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  _buildFeature() {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
        margin: const EdgeInsets.only(right: 10),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColor.blue_300,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: .5,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColor.blue_500,
                  borderRadius: BorderRadius.circular(50)),
              child: Icon(_setIcons(data["icon"]),
                  size: 20, color: AppColor.blue_700),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Text(
                (data.containsKey("quantity"))
                    ? "${data["quantity"]} ${data["name"]}"
                    : data["name"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColor.darker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _setIcons(String name) {
    switch (name) {
      case "bed":
        return Icons.bed;
      case "bathtub_outlined":
        return Icons.bathtub_outlined;
      case "kitchen":
        return Icons.kitchen;
      case "garage":
        return Icons.garage;
      case "rulerCombined":
        return FontAwesomeIcons.rulerCombined;
      case "wifi":
        return Icons.wifi;
      case "tv":
        return Icons.tv;
      case "dumbbell":
        return FontAwesomeIcons.dumbbell;
      case "swimmingPool":
        return FontAwesomeIcons.personSwimming;
      case "dog":
        return FontAwesomeIcons.dog;
      case "electricity":
        return Icons.electrical_services_rounded;
      case "hotTubPerson":
        return FontAwesomeIcons.hotTubPerson;
    }
  }
}
