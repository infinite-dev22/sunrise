import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sunrise/theme/color.dart';

class AccountCardModel {
  final double balance;

  const AccountCardModel({
    required this.balance,
  });
}

class AccountCard extends StatelessWidget {
  final AccountCardModel card;

  const AccountCard({
    required this.card,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            border: Border.all(color: Colors.white.withAlpha(30)),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withAlpha(15),
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.primary.withAlpha(130),fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatBalance(card.balance),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(130),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatBalance(double balance) {
    final balanceStr = balance.toStringAsFixed(2);
    final integerPart = balanceStr.split('.')[0];
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formatted = integerPart[i] + formatted;
      count++;
      if (count % 3 == 0 && i != 0) {
        formatted = ' $formatted';
      }
    }
    return 'UGX $formatted${balanceStr.substring(integerPart.length)}';
  }
}
