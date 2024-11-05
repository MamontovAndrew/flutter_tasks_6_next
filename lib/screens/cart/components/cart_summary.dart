import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.sum,
  });

  final int sum;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Сумма",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        Text(
          "$sum ₽",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
