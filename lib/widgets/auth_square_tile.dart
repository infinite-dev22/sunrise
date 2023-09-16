import 'package:flutter/material.dart';

class AuthSquareTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final Function() onTap;

  const AuthSquareTile(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 40,
            ),
            const SizedBox(width: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
