import 'package:flutter/material.dart';

import '../theme/color.dart';

class RaisedSettingsSection extends StatelessWidget {
  const RaisedSettingsSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              spreadRadius: .5,
              blurRadius: 1,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
          color: AppColor.appBgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(children: children),
      ),
    );
  }
}
