import 'package:flutter/material.dart';
import '../../res/dimentions.dart';
import 'components/services_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Каталог услуг",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 38),
          ServicesList(),
        ],
      ),
    );
  }
}
