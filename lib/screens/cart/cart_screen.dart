import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import '../../res/dimentions.dart';
import '../../widgets/my_text_button.dart';
import 'components/cart_list.dart';
import 'components/cart_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItemModel> cartItems = [
    CartItemModel(
      "Клинический анализ крови с лейкоцитарной формулировкой",
      690,
      1,
    ),
    CartItemModel(
      "ПЦР-тест на определение РНК коронавируса стандартный",
      1800,
      1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Корзина",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 38),
          CartList(
            items: cartItems,
            onItemChanged: (index, item) {
              setState(() {
                cartItems[index] = item;
              });
            },
            onItemRemoved: (index) {
              setState(() {
                cartItems.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 40),
          CartSummary(sum: sumCartItemsPrice()),
          const Spacer(),
          MyTextButton(
            text: "Перейти к оформлению заказа",
            onPressed: () {},
            textStyle: Theme.of(context).textTheme.bodyLarge,
            width: double.infinity,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  int sumCartItemsPrice() {
    int sum = 0;
    for (var item in cartItems) {
      sum += item.price * item.patientsNumber;
    }
    return sum;
  }
}
