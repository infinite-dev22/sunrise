import 'package:flutter/material.dart';
import 'package:sunrise/theme/color.dart';

class WideButton extends StatelessWidget {
  const WideButton(this.text,
      {super.key,
      this.color = AppColor.primary,
      this.bgColor = AppColor.secondary,
      this.onPressed});

  final String text;
  final Color color;
  final Color bgColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return _buildButton();
  }

  Widget _buildButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => bgColor),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
