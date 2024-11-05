import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import '../../../../res/dimentions.dart';
import '../../../../widgets/my_text_button.dart';

class ServiceItem extends StatelessWidget {
  const ServiceItem({
    super.key,
    required this.model,
    required this.onAddClick,
  });

  final ServiceModel model;
  final VoidCallback onAddClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingSmall),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: const BorderRadius.all(AppDimens.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.daysNumberText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 14),
                  ),
                  Text(
                    "${model.price} ₽",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const Spacer(),
              MyTextButton(
                text: "Добавить",
                onPressed: onAddClick,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
