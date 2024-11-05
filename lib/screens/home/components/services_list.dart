import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import '../../../../res/dimentions.dart';
import 'service_item.dart';

class ServicesList extends StatelessWidget {
  ServicesList({super.key});

  final List<ServiceModel> items = [
    ServiceModel(
      "ПЦР-тест на определение РНК коронавируса стандартный",
      1800,
      "2 дня",
    ),
    ServiceModel(
      "Клинический анализ крови с лейкоцитарной формулировкой",
      690,
      "1 день",
    ),
    ServiceModel(
      "Биохимический анализ крови, базовый",
      2440,
      "1 день",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: AppDimens.spacingSmall),
      itemBuilder: (context, index) {
        return ServiceItem(
          model: items[index],
          onAddClick: () {},
        );
      },
    );
  }
}
