import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../../../res/assets.dart';
import '../../../res/dimentions.dart';
import '../../../widgets/svg_icon_button.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    required this.model,
    required this.onMinusPressed,
    required this.onPlusPressed,
    required this.onDeletePressed,
  });

  final CartItemModel model;
  final VoidCallback onMinusPressed;
  final VoidCallback onPlusPressed;
  final VoidCallback onDeletePressed;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  model.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SvgIconButton(
                size: AppDimens.iconSizeSmall,
                iconPath: Assets.deleteIcon,
                onPressed: onDeletePressed,
              ),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            children: [
              Text("${model.price * model.patientsNumber} ₽"),
              const Spacer(),
              Text("${model.patientsNumber} пациент"),
              const SizedBox(width: AppDimens.spacingSmall),
              _buildCounter(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      width: 64,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: SvgIconButton(
              size: AppDimens.iconSizeSmall,
              onPressed: onMinusPressed,
              iconPath: Assets.minusIcon,
            )
          ),
          const VerticalDivider(
            width: 1,
            color: Color(0xFFEBEBEB),
            indent: 6,
            endIndent: 6,
          ),
          Expanded(
            child:SvgIconButton(
              size: AppDimens.iconSizeSmall,
              onPressed: onPlusPressed,
              iconPath: Assets.plusIcon,
            )
          ),
        ],
      ),
    );
  }
}
