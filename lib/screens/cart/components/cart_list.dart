import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../../../res/dimentions.dart';
import 'cart_item.dart';

typedef CartItemChangedCallback = void Function(int index, CartItemModel item);
typedef CartItemRemovedCallback = void Function(int index);

class CartList extends StatelessWidget {
  const CartList({
    super.key,
    required this.items,
    required this.onItemChanged,
    required this.onItemRemoved,
  });

  final List<CartItemModel> items;
  final CartItemChangedCallback onItemChanged;
  final CartItemRemovedCallback onItemRemoved;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: AppDimens.spacingSmall),
      itemBuilder: (context, index) {
        return CartItem(
          model: items[index],
          onPlusPressed: () {
            var item = items[index];
            item.patientsNumber++;
            onItemChanged(index, item);
          },
          onMinusPressed: () {
            var item = items[index];
            if (item.patientsNumber > 1) {
              item.patientsNumber--;
              onItemChanged(index, item);
            }
          },
          onDeletePressed: () {
            onItemRemoved(index);
          },
        );
      },
    );
  }
}
