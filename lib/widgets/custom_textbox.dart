import 'package:flutter/material.dart';
import 'package:sunrise/theme/color.dart';

class CustomTextBox extends StatelessWidget {
  const CustomTextBox({
    Key? key,
    this.hint = "",
    this.prefix,
    required this.suffix,
    this.controller,
    this.readOnly = false,
    required this.onChanged,
    this.onTap,
    this.autoFocus = false,
  }) : super(key: key);

  final String hint;
  final Widget? prefix;
  final Widget suffix;
  final bool readOnly;
  final bool autoFocus;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return (readOnly) ? _buildTextFieldButton() : _buildTextField();
  }

  _buildTextField() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 3),
      height: 40,
      decoration: BoxDecoration(
        color: AppColor.appBgColor,
        border: Border.all(color: AppColor.textBoxColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(.05),
            spreadRadius: .5,
            blurRadius: .5,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: readOnly,
              controller: controller,
              onChanged: onChanged,
              autofocus: autoFocus,
              decoration: InputDecoration(
                prefixIcon: prefix,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          suffix,
          const SizedBox(width: 15),
        ],
      ),
    );
  }

  _buildTextFieldButton() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 3),
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.appBgColor,
          border: Border.all(color: AppColor.textBoxColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(.05),
              spreadRadius: .5,
              blurRadius: .5,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextField(
          readOnly: readOnly,
          controller: controller,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: prefix,
            suffixIcon: suffix,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ));
  }
}
