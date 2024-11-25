import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(Product, int) updateCartItemQuantity;
  final Function(Product) removeFromCart;

  CartScreen({
    required this.cartItems,
    required this.updateCartItemQuantity,
    required this.removeFromCart,
  });

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice => widget.cartItems.fold(
    0,
        (sum, item) => sum + item.product.price * item.quantity,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(child: Text('Корзина пуста'))
                : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          widget.removeFromCart(cartItem.product);
                          setState(() {});
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Удалить',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.network(
                      cartItem.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      cartItem.product.name,
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            int newQuantity = cartItem.quantity - 1;
                            widget.updateCartItemQuantity(
                                cartItem.product, newQuantity);
                            setState(() {});
                          },
                          icon: Icon(Icons.remove),
                        ),
                        Text('${cartItem.quantity}'),
                        IconButton(
                          onPressed: () {
                            int newQuantity = cartItem.quantity + 1;
                            widget.updateCartItemQuantity(
                                cartItem.product, newQuantity);
                            setState(() {});
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(cartItem.product.price * cartItem.quantity).toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Общая сумма: ${totalPrice.toStringAsFixed(0)} ₽',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
            },
            child: Text('Купить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
