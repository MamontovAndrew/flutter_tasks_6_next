import 'package:flutter/material.dart';
import '../../../res/dimentions.dart';

class ProfileOverview extends StatelessWidget {
  const ProfileOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Эдуард",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppDimens.spacingMedium),
        Text(
          "+7 900 800-55-33",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF898A8D),
          ),
        ),
        const SizedBox(height: AppDimens.spacingSmall),
        Text(
          "email@gmail.com",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF898A8D),
          ),
        ),
      ],
    );
  }
}
